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
    @State private var departureM: DepartureMonitor? = nil
    @State private var isLoaded = false

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { departure in
                    NavigationLink {
                        SingleTripView(stop: stop, departure: departure)
                    } label: {
                        DepartureRow(departure: departure)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stop.name)
        .onAppear {
            getDeparture()
        }
    }
    
    var searchResults: [Departure] {
        let departures = departureM?.Departures ?? []
        
        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }
    
    func getDeparture() {
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest(stopid: String(stop.stopId)))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                getDeparture()
                return
            }

            guard let content = data else {
                print("No data")
                getDeparture()
                return
            }


            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    self.departureM = try decoder.decode(DepartureMonitor.self, from: content)
                    isLoaded = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        getDeparture()
                    }
                } catch {
                    print(error)
                    getDeparture()
                }
            }

        }
        task.resume()
    }
}

struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartureView(stop: stops[0])
        }
    }
}
