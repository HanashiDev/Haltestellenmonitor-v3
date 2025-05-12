//
//  MapView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    @State var tracking: MapUserTrackingMode = .none
    
    var body: some View {
        NavigationStack(path: $stopManager.presentedMapStops) {
            if #available(iOS 17.0, *) {
                MapViewNew()
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
struct MapViewNew: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    
    @State var mapStyle: MapStyle = .standard
    @State var visibleStops: [Stop] = []
    
    @State private var mapPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.050446, longitude: 13.737954),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    ))
    
    func updateStops(_ reg: MKCoordinateRegion) {
        visibleStops = stops.filter { isCoordinateInRegion($0.coordinates, region: reg) }
    }
    
    var body: some View {
        Map(position: $mapPosition) {
            ForEach(visibleStops) { stop in
                Annotation(stop.name, coordinate: stop.coordinates) {
                    NavigationLink(destination: DepartureView(stop: stop)) {
                        Image(systemName: "h.circle.fill")
                            .foregroundColor(Color("MapColor"))
                            .background(Circle().fill(Color(.systemBackground)) .shadow(radius: 1))
                    }
                }
            }
        }
        .onMapCameraChange { mapCameraUpdateContext in
            updateStops(mapCameraUpdateContext.region)
        }
        .mapStyle(mapStyle)
        .overlay {
            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    VStack {
                        Menu {
                            Button(action: {
                                mapStyle = .standard
                            }, label: {
                                Text("Standard")
                            })
                            Button(action: {
                                mapStyle = .imagery
                            }, label: {
                                Text("Satelite")
                            })
                        } label: {
                            Image(systemName: "globe.europe.africa")
                                .resizable()
                                .background(Circle().fill(Color(.systemBackground)).shadow(radius: 1))
                                .frame(width: 30, height: 30)
                                .padding(10)
                        }
                    }
                }
            }
        }.onAppear{
            if let loc = locationManager.location { // TODO: check if works
                mapPosition = MapCameraPosition.region(MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            } else {
                mapPosition = MapCameraPosition.region(locationManager._region)
            }
        }
    }
    
    func isCoordinateInRegion(_ coordinate: CLLocationCoordinate2D, region: MKCoordinateRegion) -> Bool {
        let latMin = region.center.latitude - (region.span.latitudeDelta / 2)
        let latMax = region.center.latitude + (region.span.latitudeDelta / 2)
        let lonMin = region.center.longitude - (region.span.longitudeDelta / 2)
        let lonMax = region.center.longitude + (region.span.longitudeDelta / 2)
        
        return coordinate.latitude >= latMin && coordinate.latitude <= latMax &&
        coordinate.longitude >= lonMin && coordinate.longitude <= lonMax
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
