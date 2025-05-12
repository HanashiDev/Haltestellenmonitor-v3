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
    
    @State private var pos = (MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.050446, longitude: 13.737954),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    ))
    
    var body: some View {
        NavigationStack(path: $stopManager.presentedMapStops) {
            
            if #available(iOS 17.0, *) {
                Map(initialPosition: .region(pos)) {
                    ForEach(stops) { stop in
                        Annotation(stop.name, coordinate: stop.coordinates) {
                            NavigationLink(value: stop) {
                                Image(systemName: "h.circle.fill")
                                    .foregroundColor(Color("MapColor"))
                                    .background(Circle().fill(Color(.systemBackground)) .shadow(radius: 1))
                            }
                        }
                    }
                }
            } else {
                Map(coordinateRegion: locationManager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: stops, annotationContent: { stop in
                    MapAnnotation(coordinate: stop.coordinates, content: {
                        NavigationLink(value: stop) {
                            Image(systemName: "h.circle.fill")
                                .foregroundColor(Color("MapColor"))
                                .background(Circle().fill(Color(.systemBackground)) .shadow(radius: 1))
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
}

@available(iOS 17.0, *)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
            .environmentObject(StopManager())
    }
}
