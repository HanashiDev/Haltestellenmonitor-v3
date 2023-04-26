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
    
    var stopId: Int
    var name: String
    var city: String
    var gpsX: String
    var gpsY: String
    
    var distance: Double?
    var isFavorite: Bool?
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(self.gpsX) ?? 0, longitude: Double(self.gpsY) ?? 0)
    }
    
    func getDistance() -> Int {
        return Int(distance ?? 0)
    }
    
    private enum CodingKeys : String, CodingKey {
        case stopId, name, city, gpsX, gpsY
    }
    
    func getFullName() -> String {
        return "\(name) \(city)"
    }
}
