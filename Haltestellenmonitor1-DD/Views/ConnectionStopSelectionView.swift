//
//  ConnectionStopSelectionView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct ConnectionStopSelectionView: View {
    @EnvironmentObject var favoriteStops: FavoriteStop
    @EnvironmentObject var filter: ConnectionFilter
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(searchResults, id: \.self) { stop in
                StopRow(stop: stop)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if (filter.start) {
                            filter.startStop = stop
                        } else {
                            filter.endStop = stop
                        }
                        dismiss()
                    }
            }
            .navigationTitle(filter.start ? "Startpunkt" : "Zielpunkt")
            .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var searchResults: [Stop] {
        stops = stops.sorted {
            $0.distance ?? 0 < $1.distance ?? 0
        }
        
        var newStops: [Stop] = []
        stops.forEach { stop in
            if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                newStops.append(stop)
            }
        }
        stops.forEach { stop in
            if (!favoriteStops.isFavorite(stopID: stop.stopId)) {
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

struct ConnectionStopSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStopSelectionView().environmentObject(FavoriteStop()).environmentObject(ConnectionFilter())
    }
}
