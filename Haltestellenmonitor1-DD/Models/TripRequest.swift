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
    var format: String = "json"
    
    static func getDefault(startID: Int, endID: Int, time: String?) -> TripRequest {
        return TripRequest(time: time, origin: String(startID), destination: String(endID))
    }
}
