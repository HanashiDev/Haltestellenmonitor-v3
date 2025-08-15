//
//  Coordinate.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 06.08.25.
//

struct Coordinate: Hashable, Codable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self), let double = Double(string) {
            self.value = double
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode as Double or String convertible to Double")
        }
    }

    init (_ value: Double) {
        self.value = value
    }
}
