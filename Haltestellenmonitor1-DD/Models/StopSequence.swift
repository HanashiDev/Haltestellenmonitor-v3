//
//  StopSequence.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.03.25.
//
import Foundation


struct StopSequenceItem: Hashable, Codable {
    var isGlobalId: Bool?
    var id: String
    var name: String
    var disassembledName: String?
    var type: String
    var pointType: String?
    var coord: [Int]?
    var niveau: Int
    //var parent
    var productClasses: [Int]
    var properties: properties
    struct properties: Hashable, Codable {
        var AREA_NIVEAU_DIVA: String
        var DestinationText: String
        var stoppingPointPlanned: String?
        var areaGid: String?
        var area: String
        var platform: String?
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
    
    func getTime() -> String {
        if self.getEstimatedTime() != "" {
            return self.getEstimatedTime()
        }
        
        return self.getTimetabledTime()
    }
    
    func getScheduledTime() -> String {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.getTimetabledTime())
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
    }
    
    func getRealTime() -> String {
        if (self.getEstimatedTime() == "") {
            return self.getScheduledTime()
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.getEstimatedTime())
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
    }
    
    func getTimeDifference() -> Int {
        if (self.getEstimatedTime() == "") {
            return 0
        }
        let formatter = ISO8601DateFormatter()
        let realtimeDate = formatter.date(from: self.getEstimatedTime())
        let scheduledTimeDate = formatter.date(from: self.getTimetabledTime())
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }
        
        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        var time = self.getTimetabledTime()
        if (self.getEstimatedTime() != "") {
            time = self.getEstimatedTime()
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
            return self.id.starts(with: stop.gid) // +":"
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
