//
//  SingleTripView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI
#if os(iOS)
import ActivityKit
#endif

struct SingleTripView: View {
    @EnvironmentObject var pushTokenHistory: PushTokenHistory
    @State var singleTrip: SingleTrip? = nil
    @State private var isLoaded = false
    @State private var searchText = ""
    var stop: Stop
    var departure: Departure
    
    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { tripStop in
                    if (tripStop.Position == "Current" || tripStop.Position == "Next") {
                        ZStack {
                            NavigationLink {
                                DepartureView(stop: tripStop.getStop() ?? stop)
                            } label: {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(.plain)

                            SingleTripRow(tripStop: tripStop)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .refreshable {
            getSingleTrip()
        }
        .navigationTitle(departure.getName())
        .task(id: departure.Id, priority: .userInitiated) {
            getSingleTrip()
        }
        #if os(iOS)
        .toolbar {
            Button {
                startActivity()
            } label: {
                Label("", systemImage: "pin")
            }
        }
        #endif
        .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
    }
    
    var searchResults: [TripStop] {
        if searchText.isEmpty {
            return singleTrip?.Stops ?? []
        } else {
            return (singleTrip?.Stops ?? []).filter { $0.Name.contains(searchText) }
        }
    }
    
    func getSingleTrip() {
        let url = URL(string: "https://webapi.vvo-online.de/dm/trip")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(SingleTripRequest(stopID: String(stop.stopId), tripID: departure.Id, time: departure.getDateTime().ISO8601Format()))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                return
            }

            guard let content = data else {
                print("No data")
                return
            }

            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    self.singleTrip = try decoder.decode(SingleTrip.self, from: content)
                    isLoaded = true
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func startActivity() {
        // TODO: Erfolgsmeldung anzeigen fürn Benutzer
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(time: departure.ScheduledTime, realTime: departure.RealTime)
            let attributes = TripAttributes(name: stop.name, line: departure.getName(), type: departure.Mot)
            
            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)
            
            do {
                let activity = try Activity.request(attributes: attributes, content: activityContent, pushType: .token)
                print("Requested an activity \(String(activity.id)).")
                
                Task {
                    for await data in activity.pushTokenUpdates {
                        let token = data.map {String(format: "%02x", $0)}.joined()
                        saveAcitivityOnServer(token: token)
                    }
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func saveAcitivityOnServer(token: String) {
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
                return
            }

            guard let content = data else {
                print("No data")
                return
            }
            
            print(content)
        }
        task.resume()
    }
}

struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stop: stops[0], departure: departureM.Departures[0])
        }.environmentObject(PushTokenHistory())
    }
}
