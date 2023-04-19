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
    var isarrival: Bool
    var mot: [String]
    var limit: Int
    var shorttermchanges: Bool
    var mentzonly: Bool
    var format: String
    
    static func getDefault(stopID: Int) -> DepartureRequest {
        return DepartureRequest(stopid: String(stopID), isarrival: false, mot: ["Tram","CityBus","IntercityBus","SuburbanRailway","Train","Cableway","Ferry","HailedSharedTaxi"], limit: 100, shorttermchanges: true, mentzonly: false, format: "json")
    }
}
