//
//  MapView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    @State var tracking: MapUserTrackingMode = .none

    var body: some View {
        NavigationStack(path: $stopManager.presentedMapStops) {
            Map(coordinateRegion: locationManager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: stops, annotationContent: { stop in
                MapAnnotation(coordinate: stop.coordinates, content: {
                    NavigationLink(value: stop) {
                        Image(systemName: "h.circle.fill")
                            .foregroundColor(Color("MapColor"))
                    }
                })
            })
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: Stop.self) { stop in
                DepartureView(stop: stop)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
            .environmentObject(StopManager())
    }
}
