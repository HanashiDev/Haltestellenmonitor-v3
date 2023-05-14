//
//  ConnectionStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import Foundation
import CoreLocation

struct ConnectionStop {
    var displayName: String
    var stop: Stop?
    var location: CLLocation?
    
    func getDestinationString() async -> String {
        if stop != nil {
            return String(stop?.stopId ?? 0)
        }
        if location == nil {
            return "0"
        }
        
        let coordinate = wgs2gk(wgs: location!.coordinate)
        if coordinate == nil {
            return "0"
        }
        
        let url = URL(string: "https://webapi.vvo-online.de/tr/pointfinder?limit=0&assignedstops=false&stopsOnly=false&provider=dvb&showlines=false&query=coord%3A\(Int(coordinate!.x))%3A\(Int(coordinate!.y))&format=json")!
        let request = URLRequest(url: url, timeoutInterval: 20)
        
        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            let tripPoints = try decoder.decode(Point.self, from: content)
            if tripPoints.Points.count <= 0 {
                return "0"
            }
            
            let pointComponents = tripPoints.Points.first!.components(separatedBy: "|")
            if pointComponents.count > 1 {
                return pointComponents.first!
            } else {
                return "0"
            }
        } catch {
            print(error)
            return "0"
        }
    }
}
