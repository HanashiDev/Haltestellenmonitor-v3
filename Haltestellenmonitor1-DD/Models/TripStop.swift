//
//  TripStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

struct TripStop: Hashable, Codable {
    var Id: String
    var Place: String
    var Name: String
    var Longitude: Int
    var Latitude: Int
    var Position: String
    var Platform: DeparturePlatform?
    var Time: String
    var RealTime: String?
    var State: String?
    
    func getTime() -> String {
        let date = DateParser.extractTimestamp(time: self.Time)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getRealTime() -> String {
        if (self.RealTime == nil) {
            return self.getTime()
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
        let scheduledTimeDate = DateParser.extractTimestamp(time: self.Time)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
}
