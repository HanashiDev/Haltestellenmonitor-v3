//
//  StopEvent.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

import Foundation

struct StopEvent: Hashable {
    var PreviousCalls: [CallAtStop]?
    var ThisCall: CallAtStop
    var OnwardCalls: [CallAtStop]?
    var OperatingDayRef: String
    var VehicleRef: String?
    var JourneyRef: String
    var LineRef: String
    var DirectionRef: String
    var Mode: String
    var ModeName: String
    var PublishedLineName: String
    var OperatorRef: String?
    var RouteDescription: String?
    var OriginStopPointRef: String?
    var OriginText: String?
    var DestinationStopPointRef: String?
    var DestinationText: String
    var Unplanned: String?
    var Cancelled: String?
    
    func getName() -> String {
        return "\(self.PublishedLineName) \(self.DestinationText)"
    }
    
    func getIcon() -> String {
        switch (self.Mode) {
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
    
    func getScheduledTime() -> String {
        return self.ThisCall.getScheduledTime()
    }
    
    func getRealTime() -> String {
        return self.ThisCall.getRealTime()
    }
    
    func getTimeDifference() -> Int {
        return self.ThisCall.getTimeDifference()
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        return self.ThisCall.getIn(date: date, realInTime: realInTime)
    }
    
    func getPlatForm() -> String {
        return self.ThisCall.getPlatForm()
    }
}
