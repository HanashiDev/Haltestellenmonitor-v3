//
//  SingleTripView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripView: View {
    @State var callAtStops: [CallAtStop] = []
    @State private var isLoaded = false
    @State private var searchText = ""
    var stop: Stop
    var stopEvent: StopEvent

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { callAtStop in
                    NavigationLink {
                        DepartureView(stop: callAtStop.getStop() ?? stop)
                    } label: {
                        SingleTripRow(callAtStop: callAtStop)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stopEvent.getName())
        .onAppear {
            Task {
                await getSingleTrip()
            }
        }
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
        request.httpBody = DepartureRequest(stopPointRef: stop.gid, time: self.stopEvent.ThisCall.ServiceArrival?.EstimatedTime ?? "", lineRef: self.stopEvent.LineRef, directionRef: self.stopEvent.DirectionRef, numberOfResults: 1, includeOnwardCalls: true).getXML()
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
            await getSingleTrip()
        }
    }
}

/*struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stop: stops[0], departure: departureM.Departures[0])
        }
    }
}*/
