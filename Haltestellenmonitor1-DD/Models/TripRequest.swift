//
//  TripRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct TripRequest: Hashable, Codable {
    var time: String?
    var isarrivaltime: Bool? = false
    var shorttermchanges: Bool? = true
    var origin: String
    var destination: String
    var standardSettings: TripStandardSettings?
    var format: String = "json"
}
