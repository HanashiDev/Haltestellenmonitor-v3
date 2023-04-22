//
//  SingleTripView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripView: View {
    @State var singleTrip: SingleTrip? = nil
    @State private var isLoaded = false
    @State private var searchText = ""
    var stop: Stop
    var departure: Departure

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { tripStop in
                    NavigationLink {
                        DepartureView(stop: tripStop.getStop() ?? stop)
                    } label: {
                        SingleTripRow(tripStop: tripStop)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(departure.getName())
        .onAppear {
            getSingleTrip()
        }
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
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(SingleTripRequest(stopID: String(stop.stopId), tripID: departure.Id, time: departure.getDateTime().ISO8601Format()))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                getSingleTrip()
                return
            }

            guard let content = data else {
                print("No data")
                getSingleTrip()
                return
            }

            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    self.singleTrip = try decoder.decode(SingleTrip.self, from: content)
                    isLoaded = true
                } catch {
                    print(error)
                    getSingleTrip()
                }
            }
        }
        task.resume()
    }
}

struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stop: stops[0], departure: departureM.Departures[0])
        }
    }
}
