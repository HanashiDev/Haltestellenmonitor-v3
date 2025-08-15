//
//  SingleTripView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI
import ActivityKit

struct SingleTripView: View {
    @EnvironmentObject var pushTokenHistory: PushTokenHistory
    @State var stopSequence: [StopSequenceItem] = []
    @State private var isLoaded = false
    @State private var searchText = ""
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var showingAlertSheet = false
    @State var selectedDetent: PresentationDetent = .large

    var stop: Stop
    var stopEvent: StopEvent

    var body: some View {

        Group {
            if isLoaded {
                List {
                    if stopEvent.hasInfos() {
                        HStack {
                            ZStack {
                                Button {
                                    showingAlertSheet.toggle()
                                } label: {
                                }
                                .opacity(0.0)
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Aktuelle Meldungen")
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityHint("Zeigt eine Liste der aktuellen Meldungen zu dieser Linie an")
                            .accessibilityAddTraits(.isButton)
                        }
                        .listRowBackground(Color.orange)
                    }
                    Section {
                        ForEach(searchResults, id: \.self) { stopSequenceItem in
                            ZStack {
                                NavigationLink {
                                    DepartureView(stop: stopSequenceItem.getStop() ?? stop)
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0.0)
                                .buttonStyle(.plain)

                                SingleTripRow(stopSequenceItem: stopSequenceItem)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityHint("Zeige Haltestelle \(stopSequenceItem.getStop()?.name ?? "")")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }

            } else {
                List {
                    Section {
                        ForEach(0..<12, id: \.self) { _ in
                                SingleTripRowSkeleton()
                            }
                        }
                    }
                }

        }
        .refreshable {
            await getSingleTrip()
        }
        .onAppear {
            if #available(iOS 17.0, *) {
                selectedDetent = .fraction(min(1.0, stopEvent.getInfosSize()))
            }
        }
        .sheet(
            isPresented: $showingAlertSheet,
            onDismiss: {
                if #available(iOS 17.0, *) {
                    // reset to small state
                    selectedDetent = .fraction(min(1.0, stopEvent.getInfosSize()))
                }
            }
        ) {
            DepartureInfoView(stopEvent: stopEvent, selectedDetent: $selectedDetent)
                .presentationDetents([.fraction(min(1.0, stopEvent.getInfosSize())), .large], selection: $selectedDetent)
                .presentationCornerRadius(30)
        }
        .navigationTitle("\(stopEvent.getIcon()) \(stopEvent.getName())")
        .task(id: stopEvent.transportation.properties.globalId, priority: .userInitiated) {
            await getSingleTrip()

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                    if !Task.isCancelled {
                        await getSingleTrip()
                    }
                } catch {
                    // Task was cancelled
                    break
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
        .toolbar {
            if !ProcessInfo().isiOSAppOnMac {
                Button {
                    startActivity()
                } label: {
                    Label("", systemImage: "pin")
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }

    var searchResults: [StopSequenceItem] {
        if searchText.isEmpty {
            return stopSequence
        } else {
            return stopSequence.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func getSingleTrip() async {
        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_TRIPSTOPTIMES_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"

        let date = getISO8601Date(dateString: stopEvent.departureTimePlanned)

        request.httpBody = createDepartureRequestSingle(stopId: stop.gid, line: stopEvent.transportation.id, tripCode: stopEvent.transportation.properties.tripCode ?? 0, date: getDateStampURL(date: date), time: getTimeStampURL(date: date)).data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            do {
                let stopSequenceContainer = try JSONDecoder().decode(StopSequenceContainer.self, from: content)
                let stopEvents = stopSequenceContainer.leg.stopSequence ?? []

                await MainActor.run {
                    if stopEvents.count > 0 {
                        self.stopSequence = stopEvents
                    }
                    self.isLoaded = true
                }
            } catch {
                if let jsonString = String(data: content, encoding: .utf8) {
                    print("SingleTrip JSON DECODE error: \(error)\n\n\(jsonString)")

                }
            }
        } catch {
            if !Task.isCancelled {
                print("SingleTrip error: \(error)")
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled {
                        await getSingleTrip()
                    }
                } catch {
                    // Task was cancelled during sleep
                    return
                }
            }
        }
    }

    func startActivity() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(timetabledTime: stopEvent.departureTimePlanned, estimatedTime: stopEvent.departureTimeEstimated)
            let attributes = TripAttributes(name: stop.name, icon: stopEvent.getIcon(), stopID: String(stop.stopID), lineRef: stopEvent.transportation.id, timetabledTime: stopEvent.departureTimePlanned, directionRef: "outward", publishedLineName: stopEvent.transportation.number, destinationText: stopEvent.transportation.destination.name, startTime: Date.now)

            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!, relevanceScore: Double(-state.getIn()))

            do {
                let activity = try Activity.request(attributes: attributes, content: activityContent, pushType: .token)
                print("Requested an activity \(String(activity.id)).")

                showingSuccessAlert = true

                Task {
                    for await data in activity.pushTokenUpdates {
                        let token = data.map {String(format: "%02x", $0)}.joined()
                        saveAcitivityOnServer(token: token)
                    }
                }
            } catch {
                print("SingleTrip Live Activity Start Error: \(error.localizedDescription)")
            }
        }
    }

    func saveAcitivityOnServer(token: String) {
        if pushTokenHistory.isInHistory(token: token) {
            return
        }
        pushTokenHistory.add(token: token)

        let url = URL(string: "https://dvb.hsrv.me/api/activity_v2")!
        let date = getISO8601Date(dateString: stopEvent.departureTimePlanned)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(ActivityRequest(token: token, stopID: stop.gid, line: stopEvent.transportation.id, tripCode: String(stopEvent.transportation.properties.tripCode ?? 0), date: getDateStampURL(date: date), time: getTimeStampURL(date: date)))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard error == nil else {
                print("SingleTrip Live Activity Request Error: \(error!)")
                showingErrorAlert = true
                return
            }

            guard data != nil else {
                print("SingleTrip Live Activity: No Data")
                showingErrorAlert = true
                return
            }
        }
        task.resume()
    }
}

 struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(
                stopSequence: [ StopSequenceItem(id: "1",
                                                 name: "HBF",
                                                 parent: Location(id: "de:14612:28", name: "HBF DD", disassembledName: "", type: "stop", coord: [], properties: Stop_Property(stopId: "de:14612:28")),
                                                 properties: StopSequenceItem.properties(platfromName: "1", plannedPlatformName: ""))],
                selectedDetent: PresentationDetent.large, stop: Stop.getByGID(gid: "de:14612:28")!,
                stopEvent: StopEvent(
                    location: Location(id: "de:14612:28", name: "HBF DD", disassembledName: "", type: "stop", coord: [], properties: Stop_Property(stopId: "de:14612:28")),
                    departureTimePlanned: "2025-03-26T06:00:00Z",
                    departureTimeBaseTimetable: "2025-03-26T06:00:00Z",
                    transportation: Transportation(id: "ddb:92D01: :H:j25",
                                                   number: "S1",
                                                   product: Product(name: "S-Bahn", iconId: 2),
                                                   properties: T_Properties(),
                                                   destination: Place(id: "33003598", name: "Schöna Bahnhof", type: "stop")),
                    infos: [Info(priority: "Medium",
                                 infoLinks: [ InfoLink(urlText: "", url: "", content: "Hallo Welt", subtitle: "hi")]),
                            Info(priority: "Medium",
                                 infoLinks: [ InfoLink(urlText: "", url: "", content: "Hallo Welt wie geht es dir heute mir geht es gut und dir auch? das hier ist jetzt ganz viel Text um die expansion weiter zu testen, wenn der Text länger ist soll nämlich die View weiter nach unten expandiert werden", subtitle: "hi", title: "Test"), InfoLink(urlText: "", url: "", content: "<h1>Hallö Welt</h1><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>", subtitle: "hi", title: "Test2")])]))
        }.environmentObject(PushTokenHistory())
        }
 }
