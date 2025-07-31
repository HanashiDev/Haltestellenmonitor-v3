//
//  TripLeg.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.07.25.
//
import Foundation
import SwiftUI

struct TripLeg: Hashable, Codable {
    struct TripOrigin: Hashable, Codable {
        let id: String
        let name: String
        let coord: [Double]
        let niveau: Int?
        let departureTimePlanned: String
        let departureTimeEstimated: String?
        let disassebledName: String? // Platform
    }
    struct TripDestination: Hashable, Codable {
        let id: String
        let name: String
        let coord: [Double]
        let niveau: Int?
        let arrivalTimePlanned: String
        let arrivalTimeEstimated: String?
        let disassebledName: String? // Platform
    }

    struct TripTransportation: Hashable, Codable {
        var id: String?
        // var name: String
        // var disassembledName: String?
        var number: String?
        var product: Product
        // var `operator`: Operator?
        // var origin: Place?
        var properties: T_Properties
        // var destination: Place?
    }

    let duration: Int
    let origin: TripOrigin
    let destination: TripDestination
    let transportation: TripTransportation
    // let hints: [Hint]?
    let stopSequence: [StopSequenceItem]?
    let infos: [Info]?

    let coords: [[Double]] // [(x,y)]
    struct PathDescription: Hashable, Codable {
        let name: String
        let coord: [Double] // x, y
    }
    let pathDescription: PathDescription?

    struct Interchange: Hashable, Codable {
        let desc: String
        let coords: [[Double]] // [(x,y)]
    }
    let interchange: Interchange?

    struct FootPathInfo: Hashable, Codable {
        let position: String
        let duration: Int

        struct FootPathElement: Hashable, Codable {
            let type: String
            let level: String
        }
        let footPathElem: [FootPathElement]
    }
    let footPathInfo: [FootPathInfo]?
    let footPathInfoRedundant: Bool?

    func getStartTime() -> Date {
        getISO8601Date(dateString: origin.departureTimeEstimated ?? origin.departureTimePlanned)
    }
    func getEndTime() -> Date {
        getISO8601Date(dateString: destination.arrivalTimeEstimated ?? destination.arrivalTimePlanned)
    }

    func getStartTimeString() -> String {
        getTimeStamp(date: getStartTime())
    }

    func getEndTimeString() -> String {
        getTimeStamp(date: getEndTime())
    }

    func getIconText() -> Text {
        if transportation.product.iconId == -1 {
            return Text(Image(systemName: "figure.walk"))
        }
        return Text(getIconEFA(iconId: transportation.product.iconId))
    }

    func getEndTimeWithInterchange() -> Date? {
        let endTimeWithoutInterchange = getEndTime()
        if let footPathInfo = footPathInfo {
            if let footPathInformation = footPathInfo.first {
                return Calendar.current.date(byAdding: .second, value: footPathInformation.duration, to: endTimeWithoutInterchange)
            }
        }
        return endTimeWithoutInterchange
    }

    func getNameShort() -> String {
        if transportation.product.name == "InsertedWaiting" {
            return "🕝"
        }
//        if self.Mot.type == "Footpath" {
//            return hasNoTime() ? "🕝" : "🚶"
//        }
//        /* if (self.Mot.type == "MobilityStairsUp") {
//         return "↑"
//         }
//         if (self.Mot.type == "MobilityStairsDown") {
//         return "↓"
//         }*/
//        if self.Mot.Name != nil && self.Mot.Direction == nil {
//            return self.Mot.Name!
//        }
//        if self.Mot.Name == nil && self.Mot.Direction != nil {
//            return self.Mot.Direction!
//        }
//        if self.Mot.Name == nil && self.Mot.Direction == nil {
//            return "Unbekannt"
//        }
    return getAccessibilityLabelEFA(iconId: transportation.product.iconId)
    }

    func getColor() -> Color {
        getColorEFA(iconId: transportation.product.iconId)
    }

    func getName() -> String {
        getAccessibilityLabelEFA(iconId: transportation.product.iconId)
    }

    func getAccessibilityLabel() -> String {
        getAccessibilityLabelEFA(iconId: transportation.product.iconId)
    }

    func isInsertedWaiting() -> Bool {
        transportation.product.iconId == -1
    }

    func getFirstPlatform() -> String {
        if stopSequence != nil {
            return ""
        }
        return stopSequence!.first!.getPlatform()
    }

    func getLastPlatform() -> String? {
        if stopSequence != nil {
            return ""
        }
        return stopSequence!.last!.getPlatform()
    }

    func getLastStopName() -> String {
        if stopSequence != nil {
            return ""
        }
        return stopSequence!.last!.name
    }
}

func createWaitingLeg(duration: Int, startTime: String, endTime: String) -> TripLeg {
    let startEvent = StopSequenceItem(id: "", name: "Wait", parent: Location(name: "", type: ""), properties: StopSequenceItem.properties(), departureTimePlanned: startTime, departureTimeEstimated: startTime)
    let endEvent = StopSequenceItem(id: "", name: "Wait", parent: Location(name: "", type: ""), properties: StopSequenceItem.properties(), arrivalTimePlanned: endTime, arrivalTimeEstimated: endTime)

    return TripLeg(duration: duration, origin: TripLeg.TripOrigin(id: "", name: "", coord: [], niveau: 0, departureTimePlanned: startTime, departureTimeEstimated: startTime, disassebledName: ""), destination: TripLeg.TripDestination(id: "", name: "", coord: [], niveau: 0, arrivalTimePlanned: endTime, arrivalTimeEstimated: endTime, disassebledName: ""), transportation: TripLeg.TripTransportation(id: "", product: Product(name: "InsertedWaiting", iconId: -1), properties: T_Properties()), stopSequence: [startEvent, endEvent], infos: [], coords: [], pathDescription: TripLeg.PathDescription(name: "", coord: []), interchange: TripLeg.Interchange(desc: "", coords: []), footPathInfo: [], footPathInfoRedundant: false)
}
