//
//  DateParser.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import RegexBuilder

struct DateParser {
    static func extractTimestamp(time: String) -> Date? {
        let timeRef = Reference(Int64.self)
        let timeZoneRef = Reference(Int.self)
        let pattern = Regex {
            "/Date("

            TryCapture(as: timeRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int64(match)
            }

            "-"

            TryCapture(as: timeZoneRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            ")/"
        }

        if let result = try? pattern.wholeMatch(in: time) {
            var timestamp = result[timeRef]
            timestamp = timestamp / 1000
            return Date(timeIntervalSince1970: TimeInterval(timestamp))
        }

        return nil
    }
}
