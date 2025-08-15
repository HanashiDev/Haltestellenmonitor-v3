//
//  Journey.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.07.25.
//
import Foundation
struct Journey: Hashable, Codable {
    struct TripFare: Hashable, Codable {
        struct Ticket: Hashable, Codable {
            let name: String
            let currency: String
            let priceBrutto: Double
            let priceLevel: String
            let priceLevelUnit: String
            let fromLeg: Int
            let toLeg: Int
            let person: String
        }

        let tickets: [Ticket]
    }
    let interchanges: Int
    let legs: [TripLeg]
    let fare: TripFare

    var tripFareString: String {
        return "\(fare.tickets.first!.priceBrutto) \(fare.tickets.first!.currency)"
    }

    var tripFareDetails: String {
        return "\(fare.tickets.first!.name), \(fare.tickets.first!.priceLevelUnit) \(fare.tickets.first!.priceLevel)"
    }

    var tripFareIsForFullTrip: Bool {
        return (fare.tickets.first!.fromLeg == 0 && fare.tickets.first!.toLeg == legs.count - 1)
    }

    /// Duration in Minutes
    var duration: Int {
        var totalDuration: Int = 0
        for leg in legs {
            totalDuration += leg.duration
        }
        return totalDuration / 60
    }

    func getStartTimeString() -> String {
        if legs.isEmpty {
            return ""
        }

        let date = getISO8601Date(dateString: legs.first!.origin.departureTimeEstimated ?? legs.first!.origin.departureTimePlanned)

        return getTimeStamp(date: date)
    }

    func getEndTimeString() -> String {
        if legs.isEmpty {
            return ""
        }

        // Include Possible Walking Distances etc
        let date = legs.last!.getEndTimeWithInterchange() ?? getISO8601Date(dateString: legs.last!.destination.arrivalTimeEstimated ?? legs.last!.destination.arrivalTimePlanned)

        return getTimeStamp(date: date)
    }
}
