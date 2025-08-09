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
    var previous: Bool?
    var numberprev: Int?
    var numbernext: Int?
    var sessionId: String?
    var format: String = "json"
}

enum IndividualTransportType: String, Hashable, Codable, CaseIterable {
    case walking = "100"
    case bike_and_ride = "101"
    case bike_takealong = "102"
    case park_and_ride = "104"
}

enum IndividualTransportSpeed: String, Hashable, Codable, CaseIterable {
    case fast = "fast"
    case normal = "normal"
    case slow = "slow"
}

struct TripRequestJSON: Hashable, Codable {
    var itdTime: String
    var itdDate: String
    var origin: String
    var via: String?
    var destination: String
    var individualTransport: IndividualTransportType
    var excludeTransports: TripStandardSettings? // could be MOTType
    var isarrivaltime: Bool? = false
    var numberOfTrips: Int = 5

    func createTripRequestString() -> String {
        // &coordOutputFormat=WGS84[dd.dddddd]
        var requestString = "mode=direct&outputFormat=rapidJSON&locationServerActive=1&genMaps=0&useRealtime=1&useUT=1&itdTime=\(itdTime)&itdDate=\(itdDate)&type_origin=any&name_origin=\(origin)&type_destination=any&name_destination=\(destination)&calcNumberOfTrips=\(numberOfTrips)"
        if let via = via {
            requestString += "&type_via=any&name_via=\(via)"
        }
        requestString += "&destination=\(destination)&individualTransport=\(individualTransport.rawValue)"
        if let excludeTransports = excludeTransports {
            if !excludeTransports.mot.isEmpty {
                requestString += "&excludedMeans=checkbox"
            }
            for transportType in excludeTransports.mot {
                requestString += "&exclMOT\(transportType)"
            }
        }
        if individualTransport != .walking {
            requestString += "&itOptionsActive=1&trITMOT=\(individualTransport.rawValue)"
        }

        if isarrivaltime ?? false {
            requestString += "&itdTripDateTimeDepArr=arr"
        }

        // todo: change speed

        return requestString
    }
}
