//
//  DepartureView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct DepartureView: View {
    var stop: Stop
    @State private var searchText = ""
    @State private var stopEvents: [StopEvent] = []
    @State private var isLoaded = false

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults.sorted { ($0.departureTimeEstimated ?? $0.departureTimePlanned) < ($1.departureTimeEstimated ?? $1.departureTimePlanned) }, id: \.self) { stopEvent in
                    NavigationLink {
                        SingleTripView(stop: stop, stopEvent: stopEvent)
                    } label: {
                        DepartureRow(stopEvent: stopEvent)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stop.name)
        .onAppear {
            Task {
                await getDeparture()
            }
        }
    }
    
    var searchResults: [StopEvent] {
        let departures = stopEvents

        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }
    func urlEncodedString(from parameters: [String: String]) -> String {
        return parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }

    
    func getDeparture() async {
        
        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_DM_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        
        request.httpBody = createDepartureRequest(stopId: stop.gid, itdDate: dateFormatter.string(from: Date()), itdTime: timeFormatter.string(from: Date())).data(using: .utf8)
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
            print ("error: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    await getDeparture()
                }
            }
        }
    }
}

//struct DepartureView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            DepartureView(stop: stops[0])
//        }
//    }
//}
