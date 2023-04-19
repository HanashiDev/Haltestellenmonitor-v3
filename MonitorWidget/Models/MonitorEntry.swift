//
//  MonitorEntry.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//

import WidgetKit
import SwiftUI
import Intents

struct MonitorEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let departureMonitor: DepartureMonitor?
    
    func getStopID() -> String {
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
        if (lineFilters == nil || lineFilters?.isEmpty == true) {
            return departures
        }
        
        var newDepartures: [Departure] = []
        
        departures.forEach { departure in
            if (lineFilters?.contains(departure.LineName) == true) {
                newDepartures.append(departure)
            }
        }
        
        return newDepartures
    }
}
