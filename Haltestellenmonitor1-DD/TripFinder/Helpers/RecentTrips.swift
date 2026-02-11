//
//  RecentTrips.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 11.02.26.
//

import Foundation

let USERDEFAULTS_KEY_RECENTTRIPS = "RecentTrips"


struct RecentTrip : Codable, Identifiable {
    let id: UUID
    let start, end: String
    
    init(start: String, end: String) {
        self.id = UUID()
        self.start = start
        self.end = end
    }
}

func addRecentTrip(_ start: String, _ end: String) {
    let newElement = RecentTrip(start: start, end: end)
    // Push new entry to the top is already in array
    var array : [RecentTrip] = getRecentTrips().filter({
        $0.start != newElement.start && $0.end != newElement.end})
    
    array.append(newElement)
    
    print("Add?: \(start) -> \(end)")
    
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

func getRecentTrips() -> [RecentTrip] {
   // UserDefaults.standard.removeObject(forKey: USERDEFAULTS_KEY_RECENTTRIPS)
    let defaults = UserDefaults.standard
    
    if let data = defaults.data(forKey: USERDEFAULTS_KEY_RECENTTRIPS) {
        return try! PropertyListDecoder().decode([RecentTrip].self, from: data)
    }
    return []
}

func getStopName(_ stopdID: String) -> String? {
    return stops.filter({$0.stopID == Int(stopdID)}).first?.name
}
