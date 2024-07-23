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
    let stop: Stop?
    let stopEvents: [StopEvent]?
    let widgetLocationManager = WidgetLocationManager()
    
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
    
    func filterStopEvents(stopEvents: [StopEvent]) -> [StopEvent] {
        let lineFilters = self.getLineFilters()
        var newStopEvents: [StopEvent] = []
        
        stopEvents.forEach { stopEvent in
            var embed = true
            if (lineFilters != nil || lineFilters?.isEmpty == false) {
                embed = lineFilters?.contains(stopEvent.PublishedLineName) == true
            }
            if (!embed) {
                return
            }
            
            if (stopEvent.getIn(date: self.date, realInTime: true) >= 0) {
                newStopEvents.append(stopEvent)
            }
        }
        
        return newStopEvents
    }
}
