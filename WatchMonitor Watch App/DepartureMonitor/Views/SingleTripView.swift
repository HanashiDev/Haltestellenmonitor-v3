//
//  SingleTripView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripView: View {
    @State var stopSequence: [StopSequenceItem] = []
    @State private var isLoaded = false
    @State private var searchText = ""
    @State private var backgroundTask: Task<Void, Never>?
    var stop: Stop
    var stopEvent: StopEvent

    var body: some View {
        Group {
            if isLoaded {
                List(searchResults, id: \.self) { stopSequenceItem in
                    NavigationLink {
                        DepartureView(stop: stopSequenceItem.getStop() ?? stop)
                    } label: {
                        SingleTripRow(stopSequenceItem: stopSequenceItem)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stopEvent.getName())
        .task(id: stopEvent.transportation.properties.globalId, priority: .userInitiated) {
            // Cancel any existing background task
            backgroundTask?.cancel()

            backgroundTask = Task {
                await startContinuousFetching()
            }
        }
        .onDisappear {
            backgroundTask?.cancel()
        }
    }

    var searchResults: [StopSequenceItem] {
        if searchText.isEmpty {
            return stopSequence
        } else {
            return stopSequence.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func startContinuousFetching() async {
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

    func getSingleTrip() async {
        if Task.isCancelled {
            return
        }

        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_TRIPSTOPTIMES_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"

        let date = getISO8601Date(dateString: stopEvent.departureTimePlanned)

        request.httpBody = createDepartureRequestSingle(stopId: stop.gid, line: stopEvent.transportation.id, tripCode: stopEvent.transportation.properties.tripCode ?? 0, date: getDateStampURL(date: date), time: getTimeStampURL(date: date)).data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            let stopSequenceContainer = try JSONDecoder().decode(StopSequenceContainer.self, from: content)
            let stopEvents = stopSequenceContainer.leg.stopSequence ?? []
            await MainActor.run {
                if stopEvents.count > 0 {
                    self.stopSequence = stopEvents
                }
                self.isLoaded = true
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
}

/*struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stop: stops[0], departure: departureM.Departures[0])
        }
    }
}*/
