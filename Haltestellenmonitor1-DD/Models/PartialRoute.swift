//
//  PartialRoute.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct PartialRoute: Hashable, Codable {
    var Mot: Mot
    var RegularStops: [RegularStop]?
    
    func getName() -> String {
        if (self.Mot.type == "Footpath") {
            return "Fußweg"
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
    
    func getIcon() -> String {
        print(self.Mot.type)
        switch (self.Mot.type) {
        case "Tram":
            return "cablecar"
        case "CityBus":
            return "bus"
        case "PlusBus":
            return "bus"
        case "Bus":
            return "bus"
        case "IntercityBus":
            return "bus"
        case "SuburbanRailway":
            return "tram"
        case "Train":
            return "tram"
        case "Cableway":
            return "cablecar"
        case "Ferry":
            return "ferry"
        case "HailedSharedTaxi":
            return "car"
        case "Footpath":
            return "figure.walk"
        default:
            return "cablecar"
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
    
    func getStartTimeString() -> String {
        let date = self.getStartTime()
        if (date == nil) {
            return "00:00"
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
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
    
    func getEndTimeString() -> String {
        let date = self.getEndTime()
        if (date == nil) {
            return "00:00"
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
}
