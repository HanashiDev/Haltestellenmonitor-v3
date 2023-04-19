//
//  RegularStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct RegularStop: Hashable, Codable {
    var ArrivalTime: String
    var DepartureTime: String
    var ArrivalRealTime: String?
    var DepartureRealTime: String?
    var Place: String
    var Name: String
    var type: String
    var Latitude: Int
    var Longitude: Int
    var DepartureState: String?
    var ArrivalState: String?
    
    private enum CodingKeys : String, CodingKey {
        case ArrivalTime, DepartureTime, ArrivalRealTime, DepartureRealTime, Place, Name, type = "Type", Latitude, Longitude, DepartureState, ArrivalState
    }
}
