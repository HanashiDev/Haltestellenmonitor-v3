//
//  Stop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import CoreLocation

struct Stop: Hashable, Codable, Identifiable {
    let id = UUID()

    var stopPointRef: String
    var stopPointName: String
    var locationName: String
    var longitude: String
    var latitude: String
    
    var distance: Double?
    var isFavorite: Bool?
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(self.latitude) ?? 0, longitude: Double(self.longitude) ?? 0)
    }
    
    func getDistance() -> Int {
        return Int(distance ?? 0)
    }
    
    private enum CodingKeys : String, CodingKey {
        case stopPointRef, stopPointName, locationName, longitude, latitude
    }
    
    func getFullName() -> String {
        return "\(stopPointName) \(locationName)"
    }
}
