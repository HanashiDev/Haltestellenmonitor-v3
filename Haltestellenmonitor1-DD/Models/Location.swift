//
//  Location.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 27.02.25.
//

struct Properties: Hashable, Codable {
    var stopId: String
    var area: String?
}

class Location: Hashable, Codable {
    var id: String?
    // var isGlobalId: Bool?
    var name: String
    var disassembledName: String?
    var type: String
    var coord: [Int]?
    var properties: Stop_Property
    // var parent: Location?

//    init(Id: String, IsGlobalId: Bool, Name: String, DisassembledName: String, type: String, Coord: [Int], Properties: Stop_Property, Parent: Location? = nil) {
    init(Id: String, IsGlobalId: Bool, Name: String, DisassembledName: String, type: String, Coord: [Int], Properties: Stop_Property) {
        self.id = Id
        // self.isGlobalId = IsGlobalId
        self.name = Name
        self.type = type
        self.coord = Coord
        self.properties = Properties
        // self.parent = Parent
    }

    // make class conformant to hashable
    static func == (lhs: Location, rhs: Location) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    // make class conformant to codeable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // try container.encode(isGlobalId, forKey: .isGlobalId)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(coord, forKey: .coord)
        try container.encode(properties, forKey: .properties)
//        try container.encode(parent, forKey: .parent)
    }
    }
