//
//  Service.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.07.24.
//

import Foundation

struct Service: Hashable {
    var plannedBay: String
    var timetabledTime: String
    var estimatedTime: String
    var operatingDayRef: String
    var journeyRef: String
    var ptMode: String
    var publishedLineName: String
    var destination: String
    
    func getScheduledTime() -> String {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.timetabledTime)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getRealTime() -> String {
        if (self.estimatedTime == "") {
            return self.getScheduledTime()
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.estimatedTime)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getTimeDifference() -> Int {
        if (self.estimatedTime == "") {
            return 0
        }
        let formatter = ISO8601DateFormatter()
        let realtimeDate = formatter.date(from: self.estimatedTime)
        let scheduledTimeDate = formatter.date(from: self.timetabledTime)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        var time = self.timetabledTime
        if (self.estimatedTime != "") {
            time = self.timetabledTime
        }
        let formatter = ISO8601DateFormatter()
        let timeDate = formatter.date(from: time)
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
        return "\(self.publishedLineName) \(self.destination)"
    }
    
    func getIcon() -> String {
        switch (self.ptMode) {
        case "tram":
            return "🚊"
        case "bus":
            return "🚍"
        case "trolleybus":
            return "🚍"
        case "urbanRail":
            return "🚈"
        case "rail":
            return "🚆"
        case "intercityRail":
            return "🚆"
        case "cableway":
            return "🚞"
        case "water":
            return "⛴️"
        case "taxi":
            return "🚖"
        default:
            return "🚊"
        }
    }
    
    func getPlatForm() -> String {
        if plannedBay == "" {
            return ""
        }

        return "Steig \(self.plannedBay)"
    }
}
