//
//  MonitorEntry.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//  Modified by Tom Braune on 03.11.23.
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
    let widgetLocationManager = WidgetLocationManager()
    
    func getStopID(Name : String) -> String {
        if Name == "_" {
            return configuration.stopType?.identifier ?? "33000028"
        }
        
        // Retriving the stopID by the Stops' name
        let stop = stops.first(where: { String($0.name) == Name })
        
        if stop != nil {
            return String(stop!.stopID)
        }
        
        return configuration.stopType?.identifier ?? "33000028"
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
