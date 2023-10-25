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
            return hasNoTime() ? "Warten" : "Fußweg"
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
    
    func shouldBeBold() -> Bool {
        !(self.Mot.type == "Footpath" || self.Mot.type == "MobilityStairsUp" ||  self.Mot.type == "MobilityStairsDown")
    }
    
    func hasNoTime() -> Bool {
        return getStartTimeString() == nil || getEndTimeString() == nil
    }
    
    func getNameShort() -> String {
        if (self.Mot.type == "Footpath") {
            return hasNoTime() ? "🕝" : "🚶"
        }
        if (self.Mot.type == "MobilityStairsUp") {
            return "↑"
        }
        if (self.Mot.type == "MobilityStairsDown") {
            return "↓"
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
    
    func getColor() -> Color { // TODO: replace purple colors
        let opacity = 0.8
        switch (self.Mot.type) {
        case "Tram":
            return Color.red.opacity(opacity)
        case "CityBus":
            return Color.blue.opacity(opacity)
        case "PlusBus":
            return Color.blue.opacity(opacity)
        case "Bus":
            return Color.blue.opacity(opacity)
        case "IntercityBus":
            return Color.blue.opacity(opacity)
        case "SuburbanRailway":
            return Color.green.opacity(opacity)
        case "RapidTransit":
            return Color.green.opacity(opacity)
        case "Train":
            return Color.green.opacity(opacity)
        case "Cableway":
            return Color.purple.opacity(opacity)
        case "Ferry":
            return Color.purple.opacity(opacity)
        case "HailedSharedTaxi":
            return Color.yellow.opacity(opacity)
        case "Footpath":
            return Color.gray.opacity(opacity)
        case "MobilityStairsUp":
            return Color.purple.opacity(opacity)
        case "MobilityStairsDown":
            return Color.purple.opacity(opacity)
        default:
             return Color.purple.opacity(opacity)
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
