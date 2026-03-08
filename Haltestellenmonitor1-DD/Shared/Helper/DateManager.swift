//
//  DateManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 20.04.25.
//

import Foundation
import SwiftUI

func getTimeStamp(date: Date) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "HH:mm"
    return dFormatter.string(for: date) ?? "n/a"
}

func getTimeStampURL(date: Date = Date()) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "HHmm"
    return dFormatter.string(for: date) ?? ""
}

func getDateStampURL(date: Date = Date()) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "yyyyMMdd"
    return dFormatter.string(for: date) ?? ""
}

func getISO8601Date(dateString: String?) -> Date {
    if let dateString = dateString {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date.now
    }
    return Date.now
}

extension Date {
    /// Find the difference between two dates
    /// - Returns: difference in ms
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

// amybe move somewhere else
func styledDepartureTime(_ text: String) -> AttributedString {
    var attr = AttributedString(text)
    var textColor = Color.blue
    
    if text.count > 5 {
        let signCharIndex = text.index(text.startIndex, offsetBy: 5)
        
        if text[signCharIndex] != "-" {
            textColor = .red
        }
    }
    
    if let start = attr.characters.index(attr.startIndex, offsetBy: 5, limitedBy: attr.endIndex), start < attr.endIndex {
        attr[start..<attr.endIndex].foregroundColor = textColor
    }
    return attr
}

/// Creates a formatted string of the start time with delay
func formatTimeWithDelay(_ time: String?, _ actualTime: String?) -> String? {
    var delay: Int = 0
    var baseTime = "";
    
    if let realDepartureTime = actualTime {
        baseTime = realDepartureTime
        
        if let departureTime = time {
            baseTime = departureTime
            
            // Delayed, or to early
            if actualTime != time {
                let departureDate = DateParser.extractTimestamp(time: departureTime)
                let realDepartureDate = DateParser.extractTimestamp(time: realDepartureTime)
    
                if departureDate != nil && realDepartureDate != nil {
                    delay = Int(realDepartureDate! - departureDate!)/60
                }
                baseTime = departureTime
            }
        } else {
            baseTime = realDepartureTime
        }
    } else {
        return nil
    }
    
    let date = DateParser.extractTimestamp(time: baseTime)
    
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "HH:mm"
    let formattedString = dFormatter.string(for: date) ?? ""
    return formattedString + (delay != 0 ? String(format: "%+d", delay) : "")
}
