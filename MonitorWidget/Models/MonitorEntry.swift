//
//  MonitorEntry.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//

import WidgetKit
import SwiftUI
import Intents
import CoreLocation
import MapKit

struct MonitorEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let departureMonitor: DepartureMonitor?
    
    func getStopID() -> String {
        var favoriteStops: [Int] = []
        
        if configuration.favoriteFilter == FavoriteFilter.true {
            let sharedUserDefaults = UserDefaults(suiteName: "group.dev.hanashi.Haltestellenmonitor")
            if let decoded = sharedUserDefaults?.array(forKey: "WidgetFavs") as? [Int]{
                favoriteStops = decoded
            }

            var favStops = stops.filter{ favorite in
                return favoriteStops.contains(favorite.stopId)
            }
            if favStops.isEmpty {
                return "33000028"
            } else {
//                let locationM = CLLocationManager()
                
//                ForEach(favStops) {stop in
//                    var newStop = stop
//                    newstop.distance = location.distance(from: CLLocation(latitude: stop.coordinates.latitude, longitude: stop.coordinates.longitude))
//                }
                favStops = favStops.sorted{$0.distance ?? 0 > $1.distance ?? 0}
                return String(favStops[0].stopId)
            }
        }
        return configuration.stopType?.identifier ?? "33000028"
    }
    
    func getStopName() -> String {
        let stopID = self.getStopID()
        let stop = stops.first(where: { String($0.stopId) == stopID })
        return stop?.name ?? "Unbekannt"
    }
    
    func getLineFilters() -> [String]? {
        if (configuration.lineFilter == nil || configuration.lineFilter?.isEmpty == true) {
            return nil
        }
        var lines: [String] = []
        configuration.lineFilter?.forEach { line in
            lines.append(line.identifier!)
        }
        if (lines.isEmpty) {
            return nil
        }
        
        return lines
    }
    
    func filterDepartures(departures: [Departure]) -> [Departure] {
        let lineFilters = self.getLineFilters()
        var newDepartures: [Departure] = []
        
        departures.forEach { departure in
            var embed = true
            if (lineFilters != nil || lineFilters?.isEmpty == false) {
                embed = lineFilters?.contains(departure.LineName) == true
            }
            if (!embed) {
                return
            }
            
            if (departure.getIn(date: self.date, realInTime: true) >= 0) {
                newDepartures.append(departure)
            }
        }
        
        return newDepartures
    }
}
