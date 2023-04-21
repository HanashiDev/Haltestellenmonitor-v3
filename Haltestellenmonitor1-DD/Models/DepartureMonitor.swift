//
//  DepartureM.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

struct DepartureMonitor: Hashable, Codable {
    var Name: String?
    var Status: DepartureStatus
    var Place: String?
    var ExpirationTime: String?
    var Departures: [Departure]
}
