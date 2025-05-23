//
//  ContentView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager: LocationManager = LocationManager()
    @StateObject var favoriteStops: FavoriteStop = FavoriteStop()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(searchResults, id: \.self) { stop in
                NavigationLink(value: stop) {
                    StopRow(stop: stop)
                }
                    .swipeActions(edge: .trailing) {
                        if favoriteStops.isFavorite(stopID: stop.stopID) {
                            Button {
                                favoriteStops.remove(stopID: stop.stopID)
                            } label: {
                                Label("Unstar", systemImage: "star.fill")
                            }
                            .tint(.red)
                        } else {
                            Button {
                                favoriteStops.add(stopID: stop.stopID)
                            } label: {
                                Label("Star", systemImage: "star")
                            }
                            .tint(.yellow)
                        }
                    }
            }
            .searchable(text: $searchText)
            .navigationTitle("Abfahrten")
            .navigationDestination(for: Stop.self) { stop in
                DepartureView(stop: stop)
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .toolbar {
                if #available(watchOS 10.5, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            locationManager.requestCurrentLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.primary)
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            locationManager.requestCurrentLocation()
                        } label: {
                            Image(systemName: "location.fill")
                        }
                    }
                }
            }
        }
        .environmentObject(favoriteStops)
    }

    var searchResults: [Stop] {
        stops = stops.sorted {
            $0.distance ?? 0 < $1.distance ?? 0
        }

        var newStops: [Stop] = []
        stops.forEach { stop in
            if favoriteStops.isFavorite(stopID: stop.stopID) {
                newStops.append(stop)
            }
        }
        stops.forEach { stop in
            if !favoriteStops.isFavorite(stopID: stop.stopID) {
                newStops.append(stop)
            }
        }
        stops = newStops

        if searchText.isEmpty {
            return stops
        } else {
            return stops.filter { $0.name.contains(searchText) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
