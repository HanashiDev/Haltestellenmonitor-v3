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
    @State var stopEvents: [StopEvent] = []
    @State private var searchText = ""
    @State private var isLoaded = false
    @State private var dateTime = Date.now
    @State private var topExpanded: Bool = true
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var alreadyStarted = false
    @StateObject var departureFilter = DepartureFilter()

    var body: some View {
        Group {
            if isLoaded {
                VStack {
                    Form {
                        Section {
                            DisclosureGroup("Verkehrsmittel") {
                                DepartureDisclosureSection()
                            }
                            HStack {
                                DatePicker("Zeit", selection: $dateTime)
                                Button {
                                    dateTime = Date.now
                                } label: {
                                    Text("Jetzt")
                                }
                            }
                        }
                        Section {
                            // speed-up: don't use the getter
                            // no utc conversion needed for comparison
                                List(searchResults.sorted { ($0.departureTimeEstimated ?? $0.departureTimePlanned) < ($1.departureTimeEstimated ?? $1.departureTimePlanned) }, id: \.self) { stopEvent in
                                    ZStack {
                                        NavigationLink {
                                            SingleTripView(stop: stop, stopEvent: stopEvent)
                                        } label: {
                                            EmptyView()
                                        }
                                        .opacity(0.0)
                                        .buttonStyle(.plain)

                                        DepartureRow(stopEvent: stopEvent)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        if !ProcessInfo().isiOSAppOnMac {
                                            Button {
                                                startActivity(stopEvent: stopEvent)
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
        .navigationTitle("🚏 \(stop.name)")
        .toolbar {
            Button {
                if favoriteStops.isFavorite(stopID: stop.stopID) {
                    favoriteStops.remove(stopID: stop.stopID)
                } else {
                    favoriteStops.add(stopID: stop.stopID)
                }
            } label: {
                if favoriteStops.isFavorite(stopID: stop.stopID) {
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

        .task(id: stop.id) {
            /*stopEvents = []
            isLoaded = false*/
            await getDeparture()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: dateTime) { _ in
            Task {
                await getDeparture()
            }
        }
        .environmentObject(departureFilter)
    }

    var searchResults: [StopEvent] {
        var stopEventsTmp = stopEvents
        stopEventsTmp = stopEventsTmp.filter {
            (departureFilter.tram && $0.transportation.product.iconId == 4) ||
            (departureFilter.bus && $0.transportation.product.iconId == 3) ||
            (departureFilter.suburbanRailway && $0.transportation.product.iconId == 2) ||
            (departureFilter.train && $0.transportation.product.iconId == 6) ||
            (departureFilter.cableway && $0.transportation.product.iconId == 9) ||
            (departureFilter.ferry && $0.transportation.product.iconId == 10)
        }

        if searchText.isEmpty {
            return stopEventsTmp
        } else {
            return stopEventsTmp.filter {
                $0.getName().lowercased().contains(searchText.lowercased())
            }
        }
    }

    func getDeparture() async {
        var localDateTime = dateTime
        if localDateTime < Date.now {
            localDateTime = Date.now
        }

        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_DM_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"

        request.httpBody = createDepartureRequest(stopId: stop.gid, itdDate: getDateStampURL(date: localDateTime), itdTime: getTimeStampURL(date: localDateTime)).data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            let stopEventContainer = try JSONDecoder().decode(StopEventContainer.self, from: content)
            self.stopEvents = stopEventContainer.stopEvents
            self.isLoaded = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                Task {
                    await getDeparture()
                }
            }
        } catch {
            print("DepartureMonitor error: \(error)")

            // stop infinite retries of -999 fails
            if !error.localizedDescription.contains("Abgebrochen") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Task {
                        await getDeparture()
                    }
                }
            }
        }
    }

    func startActivity(stopEvent: StopEvent) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(timetabledTime: stopEvent.departureTimePlanned, estimatedTime: stopEvent.departureTimeEstimated)
            let attributes = TripAttributes(name: stop.name, icon: stopEvent.getIcon(), stopID: String(stop.stopID), lineRef: stopEvent.transportation.getLineRef(), timetabledTime: stopEvent.departureTimePlanned, directionRef: "outward", publishedLineName: stopEvent.transportation.number, destinationText: stopEvent.transportation.destination.name)

            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)

            do {
                let activity = try Activity.request(attributes: attributes, content: activityContent, pushType: .token)
                print("Requested an activity \(String(activity.id)).")

                showingSuccessAlert = true

                Task {
                    for await data in activity.pushTokenUpdates {
                        let token = data.map {String(format: "%02x", $0)}.joined()
                        saveAcitivityOnServer(stopEvent: stopEvent, token: token)
                    }
                }
            } catch {
                print("DepartureMonitor Live Activity Start Error: \(error)")
            }
        }
    }

    func saveAcitivityOnServer(stopEvent: StopEvent, token: String) {
        if pushTokenHistory.isInHistory(token: token) {
            return
        }
        pushTokenHistory.add(token: token)

        let url = URL(string: "https://dvb.hsrv.me/api/activity")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(ActivityRequest(token: token, stopGID: stop.gid, lineRef: stopEvent.transportation.getLineRef(), directionRef: "outward", timetabledTime: stopEvent.getScheduledTime(), estimatedTime: stopEvent.getEstimatedTime()))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard error == nil else {
                print("DepartureMonitor Live Activity Request error: \(error!)")
                showingErrorAlert = true
                return
            }

            guard let content = data else {
                print("DepartureMonitor Live Activity Request: No data")
                showingErrorAlert = true
                return
            }

            print(content)
        }
        task.resume()
    }
}
//
// struct DepartureView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            DepartureView(stop: stops[100])
//        }
//            .environmentObject(FavoriteStop())
//            .environmentObject(PushTokenHistory())
//    }
// }
