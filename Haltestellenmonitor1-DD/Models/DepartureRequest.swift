//
//  DepartureRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

struct DepartureRequest: Hashable, Codable {
    var stopid: String
    var time: String?
    var isarrival: Bool = false
    var mot: [String] = ["Tram","CityBus","IntercityBus","SuburbanRailway","Train","Cableway","Ferry","HailedSharedTaxi"]
    var limit: Int = 100
    var shorttermchanges: Bool = true
    var mentzonly: Bool = false
    var format: String = "json"
}
