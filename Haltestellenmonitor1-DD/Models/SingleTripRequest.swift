//
//  SingleTripRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

struct SingleTripRequest: Hashable, Codable {
    var stopID: String
    var tripID: String
    var time: String
    var isarrival: Bool = false
    var mapdata: Bool = false
    var format: String = "json"
}
