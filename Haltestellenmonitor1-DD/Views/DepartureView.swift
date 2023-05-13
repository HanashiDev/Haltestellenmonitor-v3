//
//  DepartureView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI
import ActivityKit

struct DepartureView: View {
    var stop: Stop
    @EnvironmentObject var favoriteStops: FavoriteStop
    @EnvironmentObject var pushTokenHistory: PushTokenHistory
    @State var departureM: DepartureMonitor? = nil
    @State private var searchText = ""
    @State private var isLoaded = false
    @State private var dateTime = Date.now
    @State private var topExpanded: Bool = true
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @StateObject var departureFilter = DepartureFilter()
    
    var body: some View {
        Group {
            if (isLoaded) {
                VStack {
                    Form {
                        Section {
                            DisclosureGroup("Verkehrsmittel") {
                                DepartureDisclosureSection()
                            }
                            DatePicker("Zeit", selection: $dateTime)
                        }
                        Section {
                            List(searchResults, id: \.self) { departure in
                                ZStack {
                                    NavigationLink {
                                        SingleTripView(stop: stop, departure: departure)
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0.0)
                                    .buttonStyle(.plain)
                                    
                                    DepartureRow(departure: departure)
                                }
                                .swipeActions(edge: .trailing) {
                                    if !ProcessInfo().isiOSAppOnMac {
                                        Button {
                                            startActivity(departure: departure)
                                        } label: {
                                            Label("", systemImage: "pin")
                                        }
                                        .tint(.yellow)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .refreshable {
            if dateTime < Date.now {
                dateTime = Date.now
            }
            await getDeparture()
        }
        .navigationTitle(stop.name)
        .toolbar {
            Button {
                if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                    favoriteStops.remove(stopID: stop.stopId)
                } else {
                    favoriteStops.add(stopID: stop.stopId)
                }
            } label: {
                if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                    Label("", systemImage: "star.fill")
                } else {
                    Label("", systemImage: "star")
                }
            }
        }
        .alert("Diese Abfahrt wird nun als Live-Aktivität angezeigt.", isPresented: $showingSuccessAlert) {
            Button {
                // do nothing
            } label: {
                Text("OK")
            }
        }
        .alert("Die Live-Aktivität wurde nicht korrekt registriert. Sie wird nicht aktualisiert.", isPresented: $showingErrorAlert) {
            Button {
                // do nothing
            } label: {
                Text("OK")
            }
        }
        .task(id: stop.stopId) {
            departureM = nil
            isLoaded = false
            await getDeparture()
        }
        .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
        .onChange(of: dateTime) { newValue in
            Task {
                await getDeparture()
            }
        }
        .environmentObject(departureFilter)
    }
    
    var searchResults: [Departure] {
        var departures = departureM?.Departures ?? []
        departures = departures.filter {
            departureFilter.tram && $0.Mot == "Tram" ||
            departureFilter.bus && ($0.Mot == "CityBus" || $0.Mot == "IntercityBus" || $0.Mot == "PlusBus") ||
            departureFilter.suburbanRailway && $0.Mot == "SuburbanRailway" ||
            departureFilter.train && $0.Mot == "Train" ||
            departureFilter.cableway && $0.Mot == "Cableway" ||
            departureFilter.ferry && $0.Mot == "Ferry" ||
            departureFilter.taxi && $0.Mot == "HailedSharedTaxi"
        }
        
        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().lowercased().contains(searchText.lowercased())
            }
        }
    }

        func getDeparture() async {
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest(stopid: String(stop.stopId), time: dateTime.ISO8601Format()))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            self.departureM = try decoder.decode(DepartureMonitor.self, from: content)
            isLoaded = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                if dateTime < Date.now {
                    dateTime = Date.now
                }
                Task {
                    await getDeparture()
                }
            }
        } catch {
            print ("error: \(error)")
            await getDeparture()
        }
    }
    
    func startActivity(departure: Departure) {
        // TODO: Erfolgsmeldung anzeigen fürn Benutzer
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(time: departure.ScheduledTime, realTime: departure.RealTime)
            let attributes = TripAttributes(name: stop.name, type: departure.Mot, stopID: String(stop.stopId), departureID: departure.Id, lineName: departure.LineName, direction: departure.Direction)
            
            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)
            
            do {
                let activity = try Activity.request(attributes: attributes, content: activityContent, pushType: .token)
                print("Requested an activity \(String(activity.id)).")
                
                showingSuccessAlert = true
                
                Task {
                    for await data in activity.pushTokenUpdates {
                        let token = data.map {String(format: "%02x", $0)}.joined()
                        saveAcitivityOnServer(departure: departure, token: token)
                    }
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func saveAcitivityOnServer(departure: Departure, token: String) {
        if (pushTokenHistory.isInHistory(token: token)) {
            return
        }
        pushTokenHistory.add(token: token)
        
        let url = URL(string: "https://dvb.hsrv.me/api/activity")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(ActivityRequest(token: token, stopID: String(stop.stopId), tripID: departure.Id, time: departure.getDateTime().ISO8601Format(), scheduledTime: departure.ScheduledTime, realTime: departure.RealTime))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                showingErrorAlert = true
                return
            }

            guard let content = data else {
                print("No data")
                showingErrorAlert = true
                return
            }
            
            print(content)
        }
        task.resume()
    }
}

struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartureView(stop: stops[1])
        }
            .environmentObject(FavoriteStop())
            .environmentObject(PushTokenHistory())
    }
}
