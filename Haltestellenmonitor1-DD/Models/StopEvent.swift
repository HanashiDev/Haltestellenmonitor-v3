//
//  StopEvent.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//  Reworked by Tom Braune on 23.03.25.
//

import Foundation
import SwiftUI


// Transport Struct
struct Product: Hashable, Codable {
    var id: Int
    var `class`: Int
    var name: String
    var iconId: Int
}
struct Operator: Hashable, Codable {
    var code: String
    var id: String
    var name: String
}

struct Place: Hashable, Codable {
    var id: String
    var name: String
    var type: String
}

struct Stop_Property: Hashable, Codable {
    var occupancy: String?
    var stopId: String
    var area: String?
    var platform: String?
    var platformName: String?
    var plannedPlatformName: String?
}

struct T_Properties: Hashable, Codable {
    var trainName: String?
    var trainType: String?
    var trainNumber: String?
    var tripCode: Int?
    var lineDisplay: String?
    var isSTT: Bool?
    var globalId: String?
    var operatorUrl: String?
    var timetablePeriod: String?
    var specialFares: String?
    var validity: validity?
    struct validity: Hashable, Codable {
        var from: String
        var to: String
    }
    
}

struct Transportation: Hashable, Codable {
    var id: String
    var name: String
    var disassembledName: String?
    var number: String
    var product: Product
    var `operator`: Operator?
    var origin: Place?
    var properties: T_Properties
    var destination: Place
    
    func getLineRef() -> String {
        return properties.globalId ?? ""
    }
}

// Info Struct

struct InfoLink: Hashable, Codable {
    var urlText: String
    var url: String
    var content: String
    var subtitle: String
    var title: String?
    var additionalText: String?
    var htmlText: String?
}
struct Info: Hashable, Codable {
    var priority: String
    var id: String
    var version: Int
    var type: String
    var infoLinks: [InfoLink]
}

// Hint Struct
struct Hint: Hashable, Codable {
    var content: String
    var providerCode: String
    var url: String?
    var type: String
}

struct StopEvent: Hashable, Codable {
    
    var realtimeStatus: [String]? // ignore?
    var isCancelled: Bool?
    var isRealtimeControlled: Bool?
    var location: Location
    var departureTimePlanned: String
    var departureTimeBaseTimetable: String
    var departureTimeEstimated: String?
    
    var transportation: Transportation
   
    var infos: [Info]?
    var hints: [Hint]?
    //var properties: Stop_Property
    
    func hasInfos() -> Bool {
        return self.infos != nil
    }
    
    func hasHints() -> Bool {
        return self.hints != nil
    }
    
    
    func getName() -> String {
        if self.transportation.properties.specialFares != nil {
            return "\(self.transportation.properties.trainType ?? "") \(self.transportation.properties.trainNumber ?? "") \(self.transportation.destination.name)"
        }
        return "\(self.transportation.number) \(self.transportation.destination.name)"
    }
    
    func getIcon() -> String {
        switch (self.transportation.product.iconId) {
        case 4: // Tram
            return "🚊"
        case 3: // Bus
            return "🚍"
//        case 2: // S-Bahn
//            return "🚈"
        case 2, 6: // Zug, S-Bahn
            return "🚆"
        case 9: // cable car
            return "🚞"
        case 10: // boat
            return "⛴️"
        default: //others needed?
            return "🚊"
        }
    }
    
    func getColor() -> Color {
        let opacity = 0.8
        switch (self.transportation.product.iconId) {
        case 4:
            return Color.red.opacity(opacity)
        case 3:
            return Color.blue.opacity(opacity)
        case 2, 6:
            return Color.green.opacity(opacity)
        case 9:
            return Color.gray.opacity(opacity)
        case 10:
            return Color.cyan.opacity(opacity)
        default:
            return Color.purple.opacity(opacity)
        }
    }
    
    func getScheduledTime() -> String {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.departureTimePlanned)
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
        
    }
    
    func getEstimatedTime() -> String {
        if (self.departureTimeEstimated == nil) {
            return self.getScheduledTime()
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: self.departureTimeEstimated!)
        if (date == nil) {
            return "n/a"
        }
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? "n/a"
        
    }
    
    func getTimeDifference() -> Int {
        if (self.departureTimeEstimated == nil) {
            return 0
        }
        let formatter = ISO8601DateFormatter()
        let realtimeDate = formatter.date(from: self.departureTimeEstimated!)
        let scheduledTimeDate = formatter.date(from: self.departureTimePlanned)
        if (realtimeDate == nil || scheduledTimeDate == nil) {
            return 0
        }
        
        let calendar = Calendar.current
        
        let realtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: realtimeDate!)
        let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTimeDate!)
        
        return calendar.dateComponents([.minute], from: scheduledTimeComponents, to: realtimeComponents).minute!
    }
    
    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        var time = self.departureTimePlanned
        if (self.departureTimeEstimated != nil) {
            time = self.departureTimeEstimated!
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
        if self.location.type == "platform" && self.location.disassembledName != nil{
            return "Steig " + self.location.disassembledName!
        }
        return ""
    }
}

struct StopEventContainer: Hashable, Codable {
//    var version: String
    //var locations: [Location]
    var stopEvents: [StopEvent]
}
