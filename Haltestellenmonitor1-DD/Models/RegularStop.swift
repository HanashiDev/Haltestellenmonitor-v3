//
//  RegularStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct RegularStop: Hashable, Codable {
    var ArrivalTime: String
    var DepartureTime: String
    var ArrivalRealTime: String?
    var DepartureRealTime: String?
    var Place: String
    var Name: String
    var type: String
    var Platform: DeparturePlatform?
    var Latitude: Int
    var Longitude: Int
    var DepartureState: String?
    var ArrivalState: String?
    var DataId: String
    
    private enum CodingKeys : String, CodingKey {
        case ArrivalTime, DepartureTime, ArrivalRealTime, DepartureRealTime, Place, Name, type = "Type", Platform, Latitude, Longitude, DepartureState, ArrivalState, DataId
    }
    
    func getArrivalTime() -> String {
        let date = DateParser.extractTimestamp(time: self.ArrivalTime)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getDepartureTime() -> String {
        let date = DateParser.extractTimestamp(time: self.DepartureTime)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getRealArrivalTime() -> String {
        if (self.ArrivalRealTime == nil) {
            return self.getArrivalTime()
        }

        let date = DateParser.extractTimestamp(time: self.ArrivalRealTime!)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getRealDepartureTime() -> String {
        if (self.DepartureRealTime == nil) {
            return self.getDepartureTime()
        }

        let date = DateParser.extractTimestamp(time: self.DepartureRealTime!)
        if (date == nil) {
            return "00:00"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "00:00"
    }
    
    func getTimeDifference() -> Int {
        if (self.ArrivalRealTime == nil) {
            return 0
        }
        let realtimeDate = DateParser.extractTimestamp(time: self.ArrivalRealTime!)
        let scheduledTimeDate = DateParser.extractTimestamp(time: self.ArrivalTime)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getTimeDifferenceDeparture() -> Int {
        if (self.DepartureRealTime == nil) {
            return 0
        }
        let realtimeDate = DateParser.extractTimestamp(time: self.DepartureRealTime!)
        let scheduledTimeDate = DateParser.extractTimestamp(time: self.DepartureTime)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }

        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopId) == self.DataId
        }
    }
    
    func getPlatform() -> String? {
        switch (Platform?.type) {
        case "Railtrack":
            return "Gleis \(Platform?.Name ?? "0")"
        case "Platform":
            return "Steig \(Platform?.Name ?? "0")"
        default:
            return nil
        }
    }
}
