//
//  TripAttributes.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation
import ActivityKit

struct TripAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var time: String
        var realTime: String? = nil
        var done: Bool = false
        
        func getScheduledTime() -> String {
            let date = DateParser.extractTimestamp(time: self.time)
            if (date == nil) {
                return "00:00"
            }
            
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "HH:mm"
            return dFormatter.string(for: date) ?? "00:00"
        }
        
        func getRealTime() -> String {
            if (self.realTime == nil) {
                return self.getScheduledTime()
            }

            let date = DateParser.extractTimestamp(time: self.realTime!)
            if (date == nil) {
                return "00:00"
            }
            
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "HH:mm"
            return dFormatter.string(for: date) ?? "00:00"
        }
        
        func getTimeDifference() -> Int {
            if (self.realTime == nil) {
                return 0
            }
            let realtimeDate = DateParser.extractTimestamp(time: self.realTime!)
            let scheduledTimeDate = DateParser.extractTimestamp(time: self.time)
            if (realtimeDate == nil || scheduledTimeDate == nil) {
                return 0
            }

            let calendar = Calendar.current
            
            let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
            let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
            
            return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
        }
        
        func getIn() -> Int {
            var time = self.time
            if (self.realTime != nil) {
                time = self.realTime!
            }
            let timeDate = DateParser.extractTimestamp(time: time)
            
            let calendar = Calendar.current
            
            let timeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: timeDate!)
            let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
            
            var inTime = calendar.dateComponents([.minute], from: currentComponents, to: timeComponents).minute!
            
            if (inTime < 0) {
                inTime = 0
            }

            return inTime
        }
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var type: String
    var stopID: String
    var departureID: String
    var lineName: String
    var direction: String
    
    func getIcon() -> String {
        switch (self.type) {
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
}
