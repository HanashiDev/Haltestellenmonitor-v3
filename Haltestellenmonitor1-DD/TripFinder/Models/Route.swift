//
//  Route.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct Route: Hashable, Codable {
    var ShortDistance: Bool?
    var Interchanges: Int
    var PartialRoutes: [PartialRoute]

    func getStartTime() -> Date? {
        let regularStop = self.PartialRoutes.first?.RegularStops?.first
        if regularStop == nil {
            return nil
        }

        var time = regularStop?.DepartureTime
        if regularStop?.DepartureRealTime != nil {
            time = regularStop?.DepartureRealTime
        }
        if time == nil {
            return nil
        }

        return DateParser.extractTimestamp(time: time!)
    }

    func getStartTimeString() -> String {
        let date = self.getStartTime()
        if date == nil {
            return "00:00"
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }

    func getEndTime() -> Date? {
        let regularStop = self.PartialRoutes.last?.RegularStops?.last
        if regularStop == nil {
            return nil
        }

        var time = regularStop?.ArrivalTime
        if regularStop?.ArrivalRealTime != nil {
            time = regularStop?.ArrivalRealTime
        }
        if time == nil {
            return nil
        }

        return DateParser.extractTimestamp(time: time!)
    }

    func getEndTimeString() -> String {
        let date = self.getEndTime()
        if date == nil {
            return "00:00"
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }

    func getTimeDifference() -> Int {
        let startTime = self.getStartTime()
        let endTime = self.getEndTime()
        if startTime == nil || endTime == nil {
            return 0
        }

        let calendar = Calendar.current

        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startTime!)
        let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endTime!)

        return calendar.dateComponents([.minute], from: startComponents, to: endComponents).minute!
    }
}
