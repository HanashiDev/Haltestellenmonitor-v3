//
//  DateManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 20.04.25.
//

import Foundation

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
