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
    @State var callAtStops: [CallAtStop] = []
    @State private var isLoaded = false
    @State private var searchText = ""
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    var stop: Stop
    var stopEvent: StopEvent
    
    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { callAtStop in
                    ZStack {
                        NavigationLink {
                            DepartureView(stop: callAtStop.getStop() ?? stop)
                        } label: {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(.plain)

                        SingleTripRow(callAtStop: callAtStop)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .refreshable {
            await getSingleTrip()
        }
        .navigationTitle("\(stopEvent.getIcon()) \(stopEvent.getName())")
        .task(id: stopEvent.LineRef, priority: .userInitiated) {
            await getSingleTrip()
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
        .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
    }
    
    var searchResults: [CallAtStop] {
        if searchText.isEmpty {
            return callAtStops
        } else {
            return callAtStops.filter { $0.StopPointName.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func getSingleTrip() async {
        let url = URL(string: "https://efa.vvo-online.de/std3/trias")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = DepartureRequest(stopPointRef: stop.gid, time: self.stopEvent.ThisCall.getTime(), lineRef: self.stopEvent.LineRef, directionRef: self.stopEvent.DirectionRef, numberOfResults: 1, includeOnwardCalls: true).getXML()
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            let stopEventParser = StopEventResponseParser(data: content)
            stopEventParser.parse()
            if (stopEventParser.stopEvents.count > 0) {
                callAtStops.append(stopEventParser.stopEvents[0].ThisCall)
                callAtStops.append(contentsOf: stopEventParser.stopEvents[0].OnwardCalls ?? [])
                isLoaded = true
            }
        } catch {
            print ("error: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    await getSingleTrip()
                }
            }
        }
    }
    
    func startActivity() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(timetabledTime: stopEvent.ThisCall.getTimetabledTime(), estimatedTime: stopEvent.ThisCall.getTime())
            let attributes = TripAttributes(name: stop.name, mode: stopEvent.Mode, stopID: String(stop.stopID), lineRef: stopEvent.LineRef, timetabledTime: stopEvent.ThisCall.getTime(), directionRef: stopEvent.DirectionRef, publishedLineName: stopEvent.PublishedLineName, destinationText: stopEvent.DestinationText)
            
            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)
            
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
        request.httpBody = try? JSONEncoder().encode(ActivityRequest(token: token, stopGID: stop.gid, lineRef: stopEvent.LineRef, directionRef: stopEvent.DirectionRef, estimatedTime: stopEvent.ThisCall.getTime()))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")

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

/*struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stopEvent: StopEvent(ThisCall: CallAtStop(StopPointRef: "", StopPointName: ""), OperatingDayRef: "", JourneyRef: "", LineRef: "", DirectionRef: "", Mode: "", ModeName: "", PublishedLineName: "", DestinationText: ""), stopPointRef: "")
        }.environmentObject(PushTokenHistory())
    }
}*/
