//
//  MapView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI
import MapKit
import CoreLocation

struct ClusterAnnonation: Identifiable{
    let id = UUID()
    var coordinates: CLLocationCoordinate2D
    var count: Int
}

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    @State var tracking: MapUserTrackingMode = .none

    var body: some View {
        NavigationStack(path: $stopManager.presentedMapStops) {
            if #available(iOS 17.0, *) {
                MapViewNew()
                    .toolbar(.hidden, for: .navigationBar)
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
    @State var clusteredStops: [ClusterAnnonation] = []
    @State var mapSize: CGSize = .zero
    
    @State private var mapPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.050446, longitude: 13.737954),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    ))

    func updateStops(_ reg: MKCoordinateRegion) {
        visibleStops = stops.filter { isCoordinateInRegion($0.coordinates, region: reg) }
        
        // Apply Clustering
        if reg.span.latitudeDelta >=  2.4724687281629016 { // 6
            applyCluster(visibleStops, 100*100)
        }
        else if reg.span.latitudeDelta >=  0.8938580628807316 { // 5
            applyCluster(visibleStops, 100*60)
        }
        else if reg.span.latitudeDelta >=  0.15647030638189818 { // 4
            applyCluster(visibleStops, 100*35)
        }
        else  if reg.span.latitudeDelta >=  0.15647030638189818 { // 3
            applyCluster(visibleStops, 100*15)
        }
        else if reg.span.latitudeDelta >=  0.08432030587699302 { // 2
            applyCluster(visibleStops, 100*8)
        }
        else if reg.span.latitudeDelta >= 0.07075199248486541 { // 1
            applyCluster(visibleStops, 100*2)
        }
        else if reg.span.latitudeDelta < 0.08432030587699302 { // none
            clusteredStops = []
        }
    }
    
    func applyCluster(_ data: [Stop], _ stepSize: CLLocationDistance) {
        var coordinatesMapping: Dictionary<String, CLLocationCoordinate2D> = [:]
        var arr: Dictionary<String, Int> = [:]
        
        data.forEach { s in
            let x = coordinatesToKey(s.coordinates)
            if arr.isEmpty {
                coordinatesMapping[x] = s.coordinates
                arr[x] = 1
                return
            }
            
            let newAnnotation = CLLocation(latitude: s.coordinates.latitude, longitude: s.coordinates.longitude)
            var alreadyInThere = false
            
            arr.forEach { arrE in
                let loc = coordinatesMapping[arrE.key]!
                let existingAnnotation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                
                if existingAnnotation.distance(from: newAnnotation) <= stepSize {
                    arr[arrE.key] = (arr[arrE.key] ?? 1) + 1
                    alreadyInThere = true
                    return
                }
            }
            if alreadyInThere { return }
            // add new element
            coordinatesMapping[x] = s.coordinates
            arr[x] = 1
        }
        clusteredStops = arr.map({ (key,value) in
            ClusterAnnonation(coordinates: coordinatesMapping[key]!, count: value)
        })
    }
    
    // TODO: remove force unwrap
    func coordinatesToKey(_ coords: CLLocationCoordinate2D) -> String {
        return "\(coords.latitude)x\(coords.longitude)"
    }
    func keyToCoordinates(_ key: String) -> CLLocationCoordinate2D {
        let str = key.split(separator: "x")
        if let str1 = Double(str.first ?? "0") {
            if let str2 = Double(str.last ?? "0")  {
                return CLLocationCoordinate2D(latitude: CLLocationDegrees(str1), longitude: CLLocationDegrees(str2))
            }
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    var body: some View {
        Map(position: $mapPosition) {
            if clusteredStops.isEmpty {
                ForEach(visibleStops) { stop in
                    Annotation(stop.name, coordinate: stop.coordinates) {
                        NavigationLink(destination: DepartureView(stop: stop)) {
                            Image(systemName: "h.circle.fill")
                                .foregroundColor(Color("MapColor"))
                                .background(Circle().fill(Color(.systemBackground)) .shadow(radius: 1))
                        }
                    }
                }
            } else {
                ForEach(clusteredStops) { e in
                    Annotation(coordinate: e.coordinates) {
                        Image(systemName: "h.circle.fill")
                            .foregroundColor(.red)
                            .foregroundColor(Color("MapColor"))
                            .background(Circle().fill(Color(.systemBackground)) .shadow(radius: 1))
                    } label: {
                        Text("\(e.count)")
                    }
                }
            }
        }
        .onMapCameraChange { mapCameraUpdateContext in
            updateStops(mapCameraUpdateContext.region)
        }
        .mapStyle(mapStyle)
        .mapControls {
            MapScaleView()
            MapUserLocationButton()
            MapCompass()
        }
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
                                Text("Satellit")
                            })
                        } label: {
                            Image(systemName: "map")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 8.0)
                                    .fill(Color(UIColor { traitCollection in
                                        return traitCollection.userInterfaceStyle == .dark ?
                                            .systemGray5 :
                                        UIColor(_colorLiteralRed: 0.941, green: 0.976, blue: 0.965, alpha: 1)
                                    }))
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                                )
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                                .padding(.top, 7)
                            
                        }.padding(.trailing, 50)
                        Spacer()
                    }
                }
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
