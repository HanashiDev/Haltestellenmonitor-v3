//
//  StopsView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct StopsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoriteStops: FavoriteStop
    @EnvironmentObject var stopManager: StopManager
    @State private var searchText = ""
    @State private var visible: NavigationSplitViewVisibility = .doubleColumn

    var body: some View {
        NavigationSplitView(columnVisibility: $visible) {
            List(searchResults, id: \.self, selection: $stopManager.selectedStop) { stop in
                ZStack {
                    NavigationLink(value: stop) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(.plain)
                    
                    StopRow(stop: stop)
                }
                .swipeActions(edge: .trailing) {
                    if (favoriteStops.isFavorite(stopPointRef: stop.stopPointRef)) {
                        Button {
                            favoriteStops.remove(stopPointRef:  stop.stopPointRef)
                        } label: {
                            Label("Unstar", systemImage: "star.fill")
                        }
                        .tint(.red)
                    } else {
                        Button {
                            favoriteStops.add(stopPointRef: stop.stopPointRef)
                        } label: {
                            Label("Star", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
            .navigationTitle("🚏 Haltestellen")
            .toolbar {
                Button {
                    locationManager.requestCurrentLocation()
                } label: {
                    Label("", systemImage: "location")
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        } detail: {
            if (stopManager.selectedStop == nil) {
                EmptyView()
            } else {
                NavigationStack {
                    DepartureView(stop: stopManager.selectedStop ?? stops[0])
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            locationManager.requestLocation()
        }
        .onOpenURL { url in
            goToStop(url: url)
        }
    }
    
    func goToStop(url: URL) {
        if (url.host() != "stop" && url.host() != "trip") {
            return
        }
        let stopPointRef = String(url.pathComponents[1])
        if (stopPointRef == "") {
            return
        }
        let stop = stops.first(where: {$0.stopPointRef == stopPointRef})
        stopManager.selectedStop = stop
    }
    
    var searchResults: [Stop] {
        stops = stops.sorted {
            $0.distance ?? 0 < $1.distance ?? 0
        }
        
        var newStops: [Stop] = []
        stops.forEach { stop in
            if (favoriteStops.isFavorite(stopPointRef: stop.stopPointRef)) {
                newStops.append(stop)
            }
        }
        stops.forEach { stop in
            if (!favoriteStops.isFavorite(stopPointRef: stop.stopPointRef)) {
                newStops.append(stop)
            }
        }
        stops = newStops
        
        if searchText.isEmpty {
            return stops
        } else {
            return stops.filter { $0.getFullName().lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct StopsView_Previews: PreviewProvider {
    static var previews: some View {
        StopsView().environmentObject(FavoriteStop()).environmentObject(LocationManager()).environmentObject(StopManager())
    }
}
