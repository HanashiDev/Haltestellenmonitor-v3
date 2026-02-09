//
//  PartialRoute.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation
import SwiftUI

struct PartialRoute: Hashable, Codable {
    var Mot: Mot
    var RegularStops: [RegularStop]?

    func getName() -> String {
        if self.Mot.type == "InsertedWaiting" {
            return "Wartezeit"
        }
        if self.Mot.type == "Footpath" {
            return hasNoTime() ? "Warten - \(self.getDuration()) min " : "Fußweg - \(self.getDuration()) min"
        }
        if self.Mot.type == "MobilityStairsUp" {
            return "aufwärts führende Treppe"
        }
        if self.Mot.type == "MobilityStairsDown" {
            return "abwärts führende Treppe"
        }
        if self.Mot.Name != nil && self.Mot.Direction == nil {
            return self.Mot.Name!
        }
        if self.Mot.Name == nil && self.Mot.Direction != nil {
            return self.Mot.Direction!
        }
        if self.Mot.Name == nil && self.Mot.Direction == nil {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!) \(self.Mot.Direction!)"
    }

    func hasNoTime() -> Bool {
        return getStartTimeString() == nil || getEndTimeString() == nil
    }

    func getNameShort() -> String {
        if self.Mot.type == "InsertedWaiting" {
            return "🕝"
        }
        if self.Mot.type == "Footpath" {
            return hasNoTime() ? "🕝" : "🚶"
        }
       /* if (self.Mot.type == "MobilityStairsUp") {
            return "↑"
        }
        if (self.Mot.type == "MobilityStairsDown") {
            return "↓"
        }*/
        if self.Mot.Name != nil && self.Mot.Direction == nil {
            return self.Mot.Name!
        }
        if self.Mot.Name == nil && self.Mot.Direction != nil {
            return self.Mot.Direction!
        }
        if self.Mot.Name == nil && self.Mot.Direction == nil {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!)"
    }

    func getIconText() -> Text {
        let icon = getIconVVO(motType: self.Mot.type)
        if icon == getIconStandard(motType: .Walking) {
            return Text(Image(systemName: "figure.walk"))
        }
        return Text(icon)
    }

    func getColor() -> Color {
        getColorVVO(motType: self.Mot.type)
    }

    func getAccessibilityLabel() -> String {
        getAccessibilityLabelVVO(motType: self.Mot.type)
    }

    func getStartTime() -> Date? {
        let regularStop = self.RegularStops?.first
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

    func getStartTimeString() -> String? {
        let date = self.getStartTime()
        if date == nil {
            return nil
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? nil
    }

    func getEndTime() -> Date? {
        let regularStop = self.RegularStops?.last
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

    func getEndTimeString() -> String? {
        let date = self.getEndTime()
        if date == nil {
            return nil
        }

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        return dFormatter.string(for: date) ?? nil
    }

    func getLastStation() -> String? {
        return self.RegularStops?.last?.Name
    }

    func getFirstPlatform() -> String? {
        return RegularStops?.first?.getPlatform()
    }

    func getLastPlatform() -> String? {
        return RegularStops?.last?.getPlatform()
    }
    
    /// Calculates the Routes duration
    /// - Returns: duration in minutes
    func getDuration() -> Int {
        let start: Double = getStartTime()?.timeIntervalSince1970 ?? 0
        let end: Double = getEndTime()?.timeIntervalSince1970 ?? 0
        return Int((end - start) / 60)
    }
}
