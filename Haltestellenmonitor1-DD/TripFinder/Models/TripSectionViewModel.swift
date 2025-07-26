//
//  TripSectionViewModel.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 26.10.23.
//

import Foundation
import SwiftUI

struct TripSectionViewData {
    var width: CGFloat
    var name: String
    var color: Color
    var difference: Int
    var nr: Int

    func getNameText() -> Text {
        if name == getIconStandard(motType: .Walking) {
            return Text(Image(systemName: "figure.walk"))
        }
        return Text(name)
    }
}

class TripSectionViewModel: ObservableObject {
    @Published var journey: Journey
    @Published var routesWithWaitingTimeUnder2Min: [TripLeg] = []

    init(journey: Journey) {
        self.journey = journey
        insertWaitingTimePartialRoute()
    }

    func getTime() -> String {
        var totalDuration: Int = 0
        journey.legs.forEach {
            totalDuration += $0.duration
        }
        return "\(totalDuration / 60) Min"
    }

    func getDuration(_ leg: TripLeg) -> (Int, String) {
//        if partialRoute.Mot.type == "Footpath" && partialRoute.hasNoTime() {
//            return getWaitingTime(partialRoute, routes: route.PartialRoutes)
//        } // TODO Debug Later!
        return (leg.duration / 60, "")
    }

    func getAccessibilityInterchangesString() -> String {
        journey.interchanges == 1 ? "1 Umstieg" : "\(journey.interchanges) Umstiege"
    }

    func getWaitingTime(_ e: TripLeg, legs: [TripLeg]) -> (Int, String) {
        var value = 0
        var str = "Wartezeit"

        legs.forEach { f in
            if e == f {
                guard let index = legs.firstIndex(of: e) else { return }
                if index - 1 < 0 || index + 1 >= legs.count {
                    return
                }

                let defaultDate = Date()
                var date1 = defaultDate
                var date2  = defaultDate
                var beforeIndex = index - 1
                var afterIndex = index + 1

//                while legs[beforeIndex].duration == 0 && beforeIndex > 0 {
//                    let item = legs[beforeIndex]
//                    if item.Mot.type == "MobilityStairsUp" {
//                        str += " | Treppe ↑"
//                    } else if item.Mot.type == "MobilityStairsDown" {
//                        str += " | Treppe ↓"
//                    }
//                    beforeIndex -= 1
//                }
//
//                while legs[afterIndex].getDuration() == 0 && afterIndex <=  legs.count {
//                    let item =  legs[afterIndex]
//                    if item.Mot.type == "MobilityStairsUp" {
//                        str += " | Treppe ↑"
//                    } else if item.Mot.type == "MobilityStairsDown" {
//                        str += " | Treppe ↓"
//                    }
//                    afterIndex += 1
//                }

                date1 = legs[beforeIndex].getEndTimeWithInterchange() ?? defaultDate
                date2 = legs[afterIndex].getStartTime() ?? defaultDate

                let difference = Calendar.current.dateComponents([.minute], from: date1, to: date2).minute

                value = difference ?? 0
            }
        }

        if value < 0 {
            return (0, str)
        }
        return (value, str)
    }

    /// Insert waiting time as partial routes into the route
    func insertWaitingTimePartialRoute() {
        routesWithWaitingTimeUnder2Min = []

        var arr: [TripLeg] = []

        for leg in journey.legs { // TODO maybe replace for if not working
            let before: TripLeg? = arr.count >= 1 ? arr.last : nil

            let start = leg.getStartTime()
            let end = leg.getEndTime()

            if start == nil || end == nil {
                // Wartezeit 1
                continue
            }

            // Insert Wartezeit
            if before != nil {
                if before!.getEndTime() != start {
                    guard let insertedStart = before?.getEndTimeWithInterchange() else {
                        continue
                    }
                    guard let insertedEnd = leg.getStartTime() else {
                        continue
                    }
                    let startTime = "/Date(\(Int(insertedStart.timeIntervalSince1970)*1000)-0000)/"
                    let endTime = "/Date(\(Int(insertedEnd.timeIntervalSince1970)*1000)-0000)/"

                    let duration = getMinuteDifference(insertedStart, insertedEnd) * 60

                    arr.append(createWaitingLeg(duration: duration, startTime: startTime, endTime: endTime))
                }
            }
            // Add current element
            if start != end {
                arr.append(leg)
            }
        }
        routesWithWaitingTimeUnder2Min =  arr
    }

    /// Returns the difference of two dates in minutes
    func getMinuteDifference(_ startDate: Date, _ endDate: Date) -> Int {
        let start: Double = startDate.timeIntervalSince1970
        let end: Double = endDate.timeIntervalSince1970
        return Int((end - start) / 60)
    }

    /// Transforms all the partial route data into bars to display
    func getRouteColoredBars(_ maxWidth: CGFloat) -> [TripSectionViewData] {
        var endDates: [Date] = []
        var arr2: [TripSectionViewData] = []
        var index = 0

        for i in 0..<journey.legs.count {
            let leg = journey.legs[i]
            let before: Date? = endDates.count >= 1 ? endDates.last : nil

            // Wartezeit
            if leg.getStartTime() == nil || leg.getEndTime() == nil {
                if getDuration(leg).0 == 0 {
                    continue
                }

                guard let before = before else {
                    continue
                }

                let date = before.addingTimeInterval(TimeInterval(Double(getDuration(leg).0) * 60.0))

                let difference = getMinuteDifference(before, date)

                if difference > 0 {
                    index = index + 1
                    arr2.append(TripSectionViewData(width: 0.0, name: "", color: Color.gray.opacity(0.5), difference: difference, nr: index))
                    endDates.append(date)
                }
                continue
            }

            let start = leg.getStartTime() ?? Date()
            let end = leg.getEndTime() ?? Date()

            index = index + 1 // index for current element
            let newElementIndex = index

            // Laufzeiten
            if before != start && before != nil {
                guard let before = before else {
                    continue
                }
                let difference = getMinuteDifference(before, start)
                if difference > 0 {
                    index = index + 1
                    arr2.append(TripSectionViewData(width: 0.0, name: "", color: Color.gray.opacity(0.5), difference: difference, nr: index))
                    endDates.append(start)
                }
            }

            // Add current element
            if start != end {
                let difference = getMinuteDifference(start, end)
                if difference > 0 {
                    arr2.append(TripSectionViewData(width: 0.0, name: leg.getNameShort(), color: leg.getColor(), difference: difference, nr: newElementIndex))
                    endDates.append(end) }
            }
        }
        let maxTime: CGFloat = CGFloat(journey.duration)
        return adjustToMinWidth(maxWidth, arr2, maxTime)
    }

    func adjustToMinWidth( _ maxWidth: CGFloat, _ entrys: [TripSectionViewData], _ maxTime: Double) -> [TripSectionViewData] {
        var arr: [TripSectionViewData] = []
        var minWidth: CGFloat = 30.0 // 3 letters
        var occupiedThroughMinWidth = CGFloat(entrys.count) * minWidth

        // Adjust minWidth to be smaller if too much entrys
        var j: CGFloat = 1
        while occupiedThroughMinWidth > maxWidth && minWidth > 1.0 {
            occupiedThroughMinWidth = CGFloat(entrys.count) * minWidth - j
            minWidth = minWidth - j
            j = j + 1
        }

        let remainingWidth: CGFloat = (maxWidth - occupiedThroughMinWidth)
        let totalWidthOriginalValues = entrys.map({CGFloat(Double($0.difference)/maxTime)*maxWidth < minWidth ? 0: CGFloat(Double($0.difference)/maxTime)*maxWidth}).reduce(0.0, {(a, e) in return a + e})

        for entry in entrys {
            // should not happen lol
            if entry.difference <= 0 {
                continue
            }

            let originalPercent = Double(entry.difference) / maxTime
            let origWidth = CGFloat(originalPercent) * maxWidth

            // Size was originally smaller then minWidth
            if origWidth < minWidth {
                arr.append(TripSectionViewData(width: minWidth, name: entry.name, color: entry.color, difference: entry.difference, nr: entry.nr))
                continue
            }

            // Add values where size was originally greater then minWidth
            let newValue = ((origWidth/totalWidthOriginalValues)*remainingWidth).rounded(.toNearestOrEven)
            arr.append(TripSectionViewData(width: minWidth + newValue, name: entry.name, color: entry.color, difference: entry.difference, nr: entry.nr))
        }
        // print(arr.reduce(0, {(a, num) in return a + num.width})/maxWidth) // should be close to 1.0
        return arr
    }
}
