//
//  TripRequestShort.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import Foundation

struct TripRequestShort: Hashable, Codable {
    var id = UUID()
    var name: String
    var origin: ConnectionStop
    var destination: ConnectionStop
    var standardSettings: TripStandardSettings?
}
