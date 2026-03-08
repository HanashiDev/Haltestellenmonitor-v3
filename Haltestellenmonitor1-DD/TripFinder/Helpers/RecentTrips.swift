//
//  RecentTrips.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 11.02.26.
//

import Foundation

let USERDEFAULTS_KEY_RECENTTRIPS = "RecentTrips"

struct RecentTripsModel: Identifiable {
    let id: UUID
    let start, end: ConnectionStop
}

struct RecentTrip : Codable, Identifiable {
    let id: UUID
    let start, end: String
    let startId, endId: Int
    
    init(start: String, end: String, startId: Int, endId: Int) {
        self.id = UUID()
        self.start = start
        self.end = end
        self.startId = startId
        self.endId = endId
    }
}

func addRecentTrip(_ start: String, _ end: String, _ startId: Int, _ endId: Int) {
    let newElement = RecentTrip(start: start, end: end, startId: startId, endId: endId)
    // Push new entry to the top is already in array
    var array : [RecentTrip] = getRecentTrips().filter({
        $0.start != newElement.start && $0.end != newElement.end})
    
    array.append(newElement)
    
    if let data = try? PropertyListEncoder().encode(array) {
        UserDefaults.standard.set(data, forKey: USERDEFAULTS_KEY_RECENTTRIPS)
    }
}

func removeRecentTrip(_ element: RecentTrip) {
    let array : [RecentTrip] = getRecentTrips().filter({
        $0.start != element.start && $0.end != element.end})
    
    if let data = try? PropertyListEncoder().encode(array) {
        UserDefaults.standard.set(data, forKey: USERDEFAULTS_KEY_RECENTTRIPS)
    }
}

func getRecentTripsAsConnections() -> [RecentTripsModel] {
    return getRecentTrips().map { trip in
        let startStop = stops.first(where: {$0.stopID == trip.startId})
        let start = ConnectionStop(displayName: startStop?.getFullName() ?? "???", stop: startStop)
        
        let endStop = stops.first(where: {$0.stopID == trip.endId})
        let end = ConnectionStop(displayName: endStop?.getFullName() ?? "???", stop: endStop)
        return RecentTripsModel(id: UUID(), start: start, end: end)
    }
}

func getRecentTrips() -> [RecentTrip] {
   // UserDefaults.standard.removeObject(forKey: USERDEFAULTS_KEY_RECENTTRIPS)
    let defaults = UserDefaults.standard
    
    if let data = defaults.data(forKey: USERDEFAULTS_KEY_RECENTTRIPS) {
        return try! PropertyListDecoder().decode([RecentTrip].self, from: data)
    }
    return []
}
