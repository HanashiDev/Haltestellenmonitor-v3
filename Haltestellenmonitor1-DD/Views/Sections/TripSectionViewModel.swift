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

    init(width: CGFloat, name: String, color: Color, difference: Int, nr: Int) {
        self.width = width
        self.name = name
        self.color = color
        self.difference = difference
        self.nr = nr
    }

    init(orig: TripSectionViewData, _ difference: Int) {
        self.width = orig.width
        self.name = orig.name
        self.color = orig.color
        self.difference = difference
        self.nr = orig.nr
    }
}

class TripSectionViewModel: ObservableObject {
    @Published var route: Route
    @Published var routesWithWaitingTimeUnder2Min: [PartialRoute] = []

    init(route: Route) {
        self.route = route
        insertWaitingTimePartialRoute()
    }

    func getTime() -> String {
        "\(route.getTimeDifference()) Min"
    }

    func getUmstiege() -> String {
        route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege"
    }

    func getDuration(_ partialRoute: PartialRoute) -> (Int, String) {
        if partialRoute.Mot.type == "Footpath" && partialRoute.hasNoTime() {
            return  getWaitingTime(partialRoute, routes: route.PartialRoutes)
        }
        return (partialRoute.getDuration(), "")
    }

    func getWaitingTime(_ e: PartialRoute, routes: [PartialRoute]) -> (Int, String) {
        var value = 0
        var str = "Wartezeit"

        routes.forEach { f in
            if e == f {
                guard let index = routes.firstIndex(of: e) else { return }
                if index - 1 < 0 || index + 1 >= routes.count {
                    return
                }

                let defaultDate = Date()
                var date1 = defaultDate
                var date2  = defaultDate
                var beforeIndex = index - 1
                var afterIndex = index + 1

                while routes[beforeIndex].getDuration() == 0 && beforeIndex > 0 {
                    let item =  routes[beforeIndex]
                    if item.Mot.type == "MobilityStairsUp" {
                        str += " | Treppe ↑"
                    } else if item.Mot.type == "MobilityStairsDown" {
                        str += " | Treppe ↓"
                    }
                    beforeIndex -= 1
                }

                while routes[afterIndex].getDuration() == 0 && afterIndex <=  routes.count {
                    let item =  routes[afterIndex]
                    if item.Mot.type == "MobilityStairsUp" {
                        str += " | Treppe ↑"
                    } else if item.Mot.type == "MobilityStairsDown" {
                        str += " | Treppe ↓"
                    }
                    afterIndex += 1
                }

                date1 = routes[beforeIndex].getEndTime() ?? defaultDate
                date2 = routes[afterIndex].getStartTime() ?? defaultDate

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

        var arr: [PartialRoute] = []

        for i in 0..<route.PartialRoutes.count {
            let partialRoute = route.PartialRoutes[i]
            let before: PartialRoute? = arr.count >= 1 ? arr.last : nil

            // Wartezeit 1
            if partialRoute.getStartTime() == nil || partialRoute.getEndTime() == nil {
                continue
            }

            let start = partialRoute.getStartTime() ?? Date()
            let end = partialRoute.getEndTime() ?? Date()

            // Insert Wartezeit
            if before != nil {
                if before!.getEndTime() != start {
                    guard let insertedStart = before?.getEndTime() else {
                        continue
                    }
                    guard let  insertedEnd = partialRoute.getStartTime() else {
                        continue
                    }
                    let startTime = "/Date(\(Int(insertedStart.timeIntervalSince1970)*1000)-0000)/"
                    let endime = "/Date(\(Int(insertedEnd.timeIntervalSince1970)*1000)-0000)/"

                    let x =  PartialRoute(Mot: Mot(type: "InsertedWaiting"), RegularStops: [
                        RegularStop(ArrivalTime: startTime, DepartureTime: startTime, Place: "", Name: "x", type: "", Latitude: -1, Longitude: -1, DataId: "-1"),
                        RegularStop(ArrivalTime: endime, DepartureTime: endime, Place: "", Name: "x", type: "", Latitude: -1, Longitude: -1, DataId: "-1")
                    ])
                    arr.append(x)
                }
            }
            // Add current element
            if start != end {
                arr.append(partialRoute)
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

        for i in 0..<route.PartialRoutes.count {
            let partialRoute = route.PartialRoutes[i]
            let before: Date? = endDates.count >= 1 ? endDates.last : nil

            // Wartezeit
            if partialRoute.getStartTime() == nil || partialRoute.getEndTime() == nil {
                if getDuration(partialRoute).0 == 0 {
                    continue
                }

                guard let before = before else {
                    continue
                }

                let date = before.addingTimeInterval(TimeInterval(Double(getDuration(partialRoute).0) * 60.0))

                let difference = getMinuteDifference(before, date)

                if difference > 0 {
                    index = index + 1
                    arr2.append(TripSectionViewData(width: 0.0, name: "", color: Color.gray.opacity(0.5), difference: difference, nr: index))
                    endDates.append(date)
                }
                continue
            }

            let start = partialRoute.getStartTime() ?? Date()
            let end = partialRoute.getEndTime() ?? Date()

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
                    arr2.append(TripSectionViewData(width: 0.0, name: partialRoute.getNameShort(), color: partialRoute.getColor(), difference: difference, nr: newElementIndex))
                    endDates.append(end) }
            }
        }
        let maxTime: CGFloat = CGFloat(route.getTimeDifference())
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
