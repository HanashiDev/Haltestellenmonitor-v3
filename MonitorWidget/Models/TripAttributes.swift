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
            let date = getISO8601Date(dateString: self.timetabledTime)
            return getTimeStamp(date: date)
        }

        func getRealTime() -> String {
            if self.estimatedTime == nil {
                return self.getScheduledTime()
            }

            let date = getISO8601Date(dateString: self.estimatedTime!)
            return getTimeStamp(date: date)
        }

        func getTimeDifference() -> Int {
            if self.estimatedTime == nil {
                return 0
            }
            let realtimeDate = getISO8601Date(dateString: self.estimatedTime!)
            let scheduledTimeDate = getISO8601Date(dateString: self.timetabledTime)

            let calendar = Calendar.current

            let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate)
            let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate)

            return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
        }

        func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
            var time = self.timetabledTime
            if self.estimatedTime != nil {
                time = self.estimatedTime!
            }
            let timeDate = getISO8601Date(dateString: time)

            let calendar = Calendar.current

            let timeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: timeDate)
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

    var startTime: Date

    func getIcon() -> String {
        return self.icon
    }

    func getProgress(_ contentState: ContentState) -> Double {
        var time = contentState.timetabledTime
        if contentState.estimatedTime != nil {
            time = contentState.estimatedTime!
        }
        let timeDate = getISO8601Date(dateString: time)

        let calendar = Calendar.current

        let tripComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime, to: timeDate)
        let timeTotalTripInSeconds = tripComponents.hour! * (60*60) + tripComponents.minute! * 60 + tripComponents.second!

        let durationComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime, to: Date())
        let timeDurationInSeconds = durationComponents.hour! * (60*60) + durationComponents.minute! * 60 + durationComponents.second!

        return Double(timeDurationInSeconds) / Double(timeTotalTripInSeconds)
    }
}
