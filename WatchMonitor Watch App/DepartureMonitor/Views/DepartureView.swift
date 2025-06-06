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
            if isLoaded {
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
        .task(id: stop.id, priority: .userInitiated) {
            await getDeparture()

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                    if !Task.isCancelled {
                        await getDeparture()
                    }
                } catch {
                    // Task was cancelled
                    break
                }
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

    func getDeparture() async {
        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_DM_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"

        request.httpBody = createDepartureRequest(stopId: stop.gid, itdDate: getDateStampURL(), itdTime: getTimeStampURL()).data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            let stopEventContainer = try JSONDecoder().decode(StopEventContainer.self, from: content)
            await MainActor.run {
                self.stopEvents = stopEventContainer.stopEvents ?? []
                self.isLoaded = true
            }
        } catch {
            if !Task.isCancelled {
                print("Watch DepartureMonitor error: \(error)")
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled {
                        await getDeparture()
                    }
                } catch {
                    // Task was cancelled during sleep
                    return
                }

            }
        }
    }
}

// struct DepartureView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            DepartureView(stop: stops[0])
//        }
//    }
// }
