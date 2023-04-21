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
    @State var tracking: MapUserTrackingMode = .none
    @State var presentedStops = [Stop]()
    
    var body: some View {
        NavigationStack(path: $presentedStops) {
            Map(coordinateRegion: .constant(locationManager.region), interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: stops, annotationContent: { stop in
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
    }
}
