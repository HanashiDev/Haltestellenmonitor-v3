//
//  Journey.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.07.25.
//

struct Journey: Hashable, Codable {
    struct TripFare: Hashable, Codable {
        struct Ticket: Hashable, Codable {
            let name: String
            let currency: String
            let priceBrutto: Double
            let priceLevel: Int
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
}
