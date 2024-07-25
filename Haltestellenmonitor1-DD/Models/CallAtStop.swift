//
//  CallAtStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

import Foundation

struct CallAtStop: Hashable {
    var StopPointRef: String
    var StopPointName: String
    var NameSuffix: String?
    var PlannedBay: String?
    var EstimatedBay: String?
    var ServiceArrival: ServiceCall?
    var ServiceDeparture: ServiceCall?
    var StopSeqNumber: String?
    var DemandStop: String?
    var UnplannedStop: String?
    var NotServicedStop: String?
    var NoBoardingAtStop: String?
    var NoAlightingAtStop: String?
    
    func getTimetabledTime() -> String {
        if self.ServiceArrival?.TimetabledTime != nil {
            return self.ServiceArrival!.TimetabledTime!
        } else if self.ServiceDeparture!.TimetabledTime != nil {
            return self.ServiceDeparture!.TimetabledTime!
        }
        
        return ""
    }
    
    func getEstimatedTime() -> String {
        if self.ServiceArrival?.EstimatedTime != nil {
            return self.ServiceArrival!.EstimatedTime!
        } else if self.ServiceDeparture!.EstimatedTime != nil {
            return self.ServiceDeparture!.EstimatedTime!
        }
        
        return ""
    }
    
    func getScheduledTime() -> String {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.ServiceArrival?.TimetabledTime ?? "")
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
    }
    
    func getRealTime() -> String {
        if (self.ServiceArrival?.EstimatedTime == nil) {
            return self.getScheduledTime()
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.ServiceArrival?.EstimatedTime ?? "")
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
    }
    
    func getTimeDifference() -> Int {
        if (self.ServiceArrival?.EstimatedTime == nil) {
            return 0
        }
        let formatter = ISO8601DateFormatter()
        let realtimeDate = formatter.date(from: self.ServiceArrival?.EstimatedTime ?? "")
        let scheduledTimeDate = formatter.date(from: self.ServiceArrival?.TimetabledTime ?? "")
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        var time = self.ServiceArrival?.TimetabledTime
        if (self.ServiceArrival?.EstimatedTime != nil) {
            time = self.ServiceArrival?.EstimatedTime
        }
        let formatter = ISO8601DateFormatter()
        let timeDate = formatter.date(from: time ?? "")
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
    
    func getPlatForm() -> String {
        if self.PlannedBay == nil && self.EstimatedBay == nil {
            return ""
        }
        
        if self.EstimatedBay != nil {
            return "Steig \(self.EstimatedBay!)"
        }

        return "Steig \(self.PlannedBay!)"
    }
    
    func getStop() -> Stop? {
        return stops.first { stop in
            return self.StopPointRef.starts(with: stop.gid + ":")
        }
    }
}
