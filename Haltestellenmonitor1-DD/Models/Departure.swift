//
//  Departure.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import RegexBuilder

struct Departure: Hashable, Codable {
    var Id: String
    var DlId: String?
    var LineName: String
    var Direction: String
    var Platform: DeparturePlatform?
    var Mot: String
    var RealTime: String?
    var ScheduledTime: String
    var State: String?
    var RouteChanges: [String]?
    
    func getDateTime() -> Date {
        let date = DateParser.extractTimestamp(time: self.ScheduledTime)
        return date ?? Date.now
    }
    
    func getScheduledTime() -> String {
        let date = DateParser.extractTimestamp(time: self.ScheduledTime)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getRealTime() -> String {
        if (self.RealTime == nil) {
            return self.getScheduledTime()
        }

        let date = DateParser.extractTimestamp(time: self.RealTime!)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getTimeDifference() -> Int {
        if (self.RealTime == nil) {
            return 0
        }
        let realtimeDate = DateParser.extractTimestamp(time: self.RealTime!)
        let scheduledTimeDate = DateParser.extractTimestamp(time: self.ScheduledTime)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        var time = self.ScheduledTime
        if (self.RealTime != nil) {
            time = self.RealTime!
        }
        let timeDate = DateParser.extractTimestamp(time: time)
        if (timeDate == nil) {
            return 0
        }
        
        let calendar = Calendar.current
        
        let timeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: timeDate!)
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        var inTime = calendar.dateComponents([.minute], from: currentComponents, to: timeComponents).minute!
        
        if (!realInTime && inTime < 0) {
            inTime = 0
        }

        return inTime
    }
    
    func getName() -> String {
        return "\(self.LineName) \(self.Direction)"
    }
    
    func getIcon() -> String {
        switch (self.Mot) {
        case "Tram":
            return "🚊"
        case "CityBus":
            return "🚍"
        case "IntercityBus":
            return "🚍"
        case "SuburbanRailway":
            return "🚈"
        case "Train":
            return "🚆"
        case "Cableway":
            return "🚞"
        case "Ferry":
            return "⛴️"
        case "HailedSharedTaxi":
            return "🚖"
        default:
            return "🚊"
        }
    }
    
    func getPlatForm() -> String {
        switch (Platform?.type) {
        case "Railtrack":
            return "Gleis \(Platform?.Name ?? "0")"
        case "Platform":
            return "Steig \(Platform?.Name ?? "0")"
        default:
            return ""
        }
    }
}
