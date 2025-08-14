//
//  Location.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 27.02.25.
//

struct Location: Hashable, Codable {
    struct LocationParent: Hashable, Codable {
        var name: String
    }

    var id: String?
    // var isGlobalId: Bool?
    var name: String?
    var disassembledName: String?
    var type: String
    var coord: [Coordinate]?
    var properties: Stop_Property?
    var parent: LocationParent?
}
