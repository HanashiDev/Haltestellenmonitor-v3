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
        var timetabledTime: String
        var estimatedTime: String?
        var done: Bool = false

        func getScheduledTime() -> String {
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: self.timetabledTime)
            if date == nil {
                return "n/a"
            }

            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "HH:mm"
            return dFormatter.string(for: date) ?? "n/a"
        }

        func getRealTime() -> String {
            if self.estimatedTime == nil {
                return self.getScheduledTime()
            }

            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: self.estimatedTime ?? "")
            if date == nil {
                return "n/a"
            }

            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "HH:mm"
            return dFormatter.string(for: date) ?? "n/a"
        }

        func getTimeDifference() -> Int {
            if self.estimatedTime == nil {
                return 0
            }
            let formatter = ISO8601DateFormatter()
            let realtimeDate = formatter.date(from: self.estimatedTime ?? "")
            let scheduledTimeDate = formatter.date(from: self.timetabledTime)
            if realtimeDate == nil || scheduledTimeDate == nil {
                return 0
            }

            let calendar = Calendar.current

            let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
            let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)

            return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
        }

        func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
            var time = self.timetabledTime
            if self.estimatedTime != nil {
                time = self.estimatedTime!
            }
            let formatter = ISO8601DateFormatter()
            let timeDate = formatter.date(from: time)
            if timeDate == nil {
                return 0
            }

            let calendar = Calendar.current

            let timeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: timeDate!)
            let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

            var inTime = calendar.dateComponents([.minute], from: currentComponents, to: timeComponents).minute!

            if !realInTime && inTime < 0 {
                inTime = 0
            }

            return inTime
        }
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var icon: String
    var stopID: String
    var lineRef: String
    var timetabledTime: String
    var directionRef: String
    var publishedLineName: String
    var destinationText: String
    var cancelled: String?

    func getIcon() -> String {
        return self.icon
    }
}
