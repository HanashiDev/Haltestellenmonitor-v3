//
//  StopSequence.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.03.25.
//
import Foundation

struct StopSequenceItem: Hashable, Codable {
    // var isGlobalId: Bool?
    var id: String
    var name: String
    // var disassembledName: String?
    // var type: String
    // var pointType: String?
    // var coord: [Int]?
    // var niveau: Int
    var parent: Location
    // var productClasses: [Int]
    var properties: properties
    struct properties: Hashable, Codable {
        // var AREA_NIVEAU_DIVA: String
        // var DestinationText: String
        // var stoppingPointPlanned: String?
        // var areaGid: String?
        // var area: String
        // var platform: String?
        var platfromName: String?
        var plannedPlatformName: String?
    }
    var arrivalTimePlanned: String?
    var departureTimePlanned: String?
    var arrivalTimeEstimated: String?
    var departureTimeEstimated: String?

    func getTimetabledTime() -> String {
        if self.departureTimePlanned != nil {
            return self.departureTimePlanned!
        } else if self.arrivalTimePlanned != nil {
            return self.arrivalTimePlanned!
        }

        return ""
    }

    func getEstimatedTime() -> String {
        if self.departureTimeEstimated != nil {
            return self.departureTimeEstimated!
        } else if self.arrivalTimeEstimated != nil {
            return self.arrivalTimeEstimated!
        }

        return ""
    }

    func getScheduledTime() -> String {
        let date = getISO8601Date(dateString: self.getTimetabledTime())

        return getTimeStamp(date: date)
    }

    func getRealTime() -> String {
        if self.getEstimatedTime() == "" {
            return self.getScheduledTime()
        }

        let date = getISO8601Date(dateString: self.getEstimatedTime())

        return getTimeStamp(date: date)
    }

    func getTimeDifference() -> Int {
        if self.getEstimatedTime() == "" {
            return 0
        }
        let realtimeDate = getISO8601Date(dateString: self.getEstimatedTime())
        let scheduledTimeDate = getISO8601Date(dateString: self.getTimetabledTime())

        let calendar = Calendar.current

        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate)

        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }

    func getPlatform() -> String {
        if self.properties.plannedPlatformName == nil && self.properties.platfromName == nil {
            return ""
        }

        if self.properties.platfromName != nil {
            return "Steig \(self.properties.platfromName!)"
        }

        return "Steig \(self.properties.plannedPlatformName!)"
    }

    func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopID) == self.parent.properties?.stopId
        }
    }
}

struct StopSequenceContainer: Hashable, Codable {
    var leg: leg
    struct leg: Hashable, Codable {
        var transportation: Transportation
        var stopSequence: [StopSequenceItem]?
    }
}
