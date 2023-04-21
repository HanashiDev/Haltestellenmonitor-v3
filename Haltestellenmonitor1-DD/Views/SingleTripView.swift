//
//  SingleTripView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct SingleTripView: View {
    @State var singleTrip: SingleTrip? = nil
    @State private var isLoaded = false
    @State private var searchText = ""
    var stop: Stop
    var departure: Departure
    
    var body: some View {
        NavigationStack {
            Group {
                if (isLoaded) {
                    List(searchResults, id: \.self) { tripStop in
                        if (tripStop.Position == "Current" || tripStop.Position == "Next") {
                            SingleTripRow(tripStop: tripStop)
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
            .toolbar {
                Button {
                    
                } label: {
                    Label("", systemImage: "pin")
                }
            }
            .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(SingleTripRequest.getDefault(stopID: String(stop.stopId), tripID: departure.Id, time: departure.getDateTime().ISO8601Format()))
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
}

struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        SingleTripView(stop: stops[0], departure: departureM.Departures[0])
    }
}
