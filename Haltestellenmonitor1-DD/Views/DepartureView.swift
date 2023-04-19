//
//  DepartureView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct DepartureView: View {
    var stop: Stop
    @EnvironmentObject var favoriteStops: FavoriteStop
    @State var departureM: DepartureMonitor? = nil
    @State private var searchText = ""
    @State private var isLoaded = false
    
    var body: some View {
        NavigationStack {
            Group {
                if (isLoaded) {
                    List(searchResults, id: \.self) { departure in
                        DepartureRow(departure: departure)
                    }
                } else {
                    ProgressView()
                }
            }
            .refreshable {
                getDeparture()
            }
            .navigationTitle(stop.name)
            .toolbar {
                Button {
                    if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                        favoriteStops.remove(stopID: stop.stopId)
                    } else {
                        favoriteStops.add(stopID: stop.stopId)
                    }
                } label: {
                    if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                        Label("", systemImage: "star.fill")
                    } else {
                        Label("", systemImage: "star")
                    }
                }
            }
            .task(id: stop.stopId, priority: .userInitiated) {
                getDeparture()
            }
            .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
        }
    }
    
    var searchResults: [Departure] {
        if searchText.isEmpty {
            return departureM?.Departures ?? []
        } else {
            return (departureM?.Departures ?? []).filter { $0.getName().contains(searchText) }
        }
    }
    
    // TODO: View aller 30 Sekunden aktualisieren
    func getDeparture() {
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest.getDefault(stopID: stop.stopId))
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
                    self.departureM = try decoder.decode(DepartureMonitor.self, from: content)
                    isLoaded = true
                } catch {
                    print(error)
                }
            }

        }
        task.resume()
    }
}

struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureView(stop: stops[1]).environmentObject(FavoriteStop())
    }
}
