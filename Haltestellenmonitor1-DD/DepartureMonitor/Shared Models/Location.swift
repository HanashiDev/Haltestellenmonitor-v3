//
//  Location.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 27.02.25.
//

struct Location: Hashable, Codable {
    var id: String?
    // var isGlobalId: Bool?
    var name: String
    var disassembledName: String?
    var type: String
    var coord: [Coordinate]?
    var properties: Stop_Property?
    // var parent: Location?
}
