//
//  PartialRoute.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation
import SwiftUI

struct PartialRoute: Hashable, Codable {
    var Mot: Mot
    var RegularStops: [RegularStop]?
    
    func getName() -> String {
        if (self.Mot.type == "Footpath") {
            return "Fußweg"
        }
        if (self.Mot.type == "MobilityStairsUp") {
            return "aufwärts führende Treppe"
        }
        if (self.Mot.type == "MobilityStairsDown") {
            return "abwärts führende Treppe"
        }
        if (self.Mot.Name != nil && self.Mot.Direction == nil) {
            return self.Mot.Name!
        }
        if (self.Mot.Name == nil && self.Mot.Direction != nil) {
            return self.Mot.Direction!
        }
        if (self.Mot.Name == nil && self.Mot.Direction == nil) {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!) \(self.Mot.Direction!)"
    }
    
    func getNameShort() -> String {
        if (self.Mot.type == "Footpath") {
            return "Fußweg"
        }
        if (self.Mot.type == "MobilityStairsUp") {
            return "↑ Treppe"
        }
        if (self.Mot.type == "MobilityStairsDown") {
            return "↓ Treppe"
        }
        if (self.Mot.Name != nil && self.Mot.Direction == nil) {
            return self.Mot.Name!
        }
        if (self.Mot.Name == nil && self.Mot.Direction != nil) {
            return self.Mot.Direction!
        }
        if (self.Mot.Name == nil && self.Mot.Direction == nil) {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!)"
    }
    
    
    func getIcon() -> String {
        switch (self.Mot.type) {
        case "Tram":
            return "🚊"
        case "CityBus":
            return "🚍"
        case "PlusBus":
            return "🚍"
        case "Bus":
            return "🚍"
        case "IntercityBus":
            return "🚍"
        case "SuburbanRailway":
            return "🚈"
        case "RapidTransit":
            return "🚈"
        case "Train":
            return "🚆"
        case "Cableway":
            return "🚞"
        case "Ferry":
            return "⛴️"
        case "HailedSharedTaxi":
            return "🚖"
        case "Footpath":
            return "🚶"
        case "MobilityStairsUp":
            return "📈"
        case "MobilityStairsDown":
            return "📉"
        default:
            return "🚊"
        }
    }
    
    func getColor() -> Color { // TODO: replace purple olors
        switch (self.Mot.type) {
        case "Tram":
            return Color.red
        case "CityBus":
            return Color.blue
        case "PlusBus":
            return Color.blue
        case "Bus":
            return Color.blue
        case "IntercityBus":
            return Color.blue
        case "SuburbanRailway":
            return Color.green
        case "RapidTransit":
            return Color.green
        case "Train":
            return Color.green
        case "Cableway":
            return Color.purple
        case "Ferry":
            return Color.purple
        case "HailedSharedTaxi":
            return Color.yellow
        case "Footpath":
            return Color.gray
        case "MobilityStairsUp":
            return Color.purple
        case "MobilityStairsDown":
            return Color.purple
        default:
             return Color.purple
        }
    }
    
    func getStartTime() -> Date? {
        let regularStop = self.RegularStops?.first
        if (regularStop == nil) {
            return nil
        }
        
        var time = regularStop?.DepartureTime
        if (regularStop?.DepartureRealTime != nil) {
            time = regularStop?.DepartureRealTime
        }
        if (time == nil) {
            return nil
        }
        
        return DateParser.extractTimestamp(time: time!)
    }
    
    func getStartTimeString() -> String? {
        let date = self.getStartTime()
        if (date == nil) {
            return nil
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? nil
    }
    
    func getEndTime() -> Date? {
        let regularStop = self.RegularStops?.last
        if (regularStop == nil) {
            return nil
        }
        
        var time = regularStop?.ArrivalTime
        if (regularStop?.ArrivalRealTime != nil) {
            time = regularStop?.ArrivalRealTime
        }
        if (time == nil) {
            return nil
        }
        
        return DateParser.extractTimestamp(time: time!)
    }
    
    func getEndTimeString() -> String? {
        let date = self.getEndTime()
        if (date == nil) {
            return nil
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? nil
    }
    
    func getFirstStation() -> String? {
        return self.RegularStops?.first?.Name
    }
    
    func getLastStation() -> String? {
        return self.RegularStops?.last?.Name
    }
    
    func getFirstPlatform() -> String? {
        return RegularStops?.first?.getPlatform()
    }
    
    func getLastPlatform() -> String? {
        return RegularStops?.last?.getPlatform()
    }
    
    func getDuration() -> Int {
        let start: Double = getStartTime()?.timeIntervalSince1970 ?? 0
        let end: Double = getEndTime()?.timeIntervalSince1970 ?? 0
        return Int((end - start) / 60)
    }
}
