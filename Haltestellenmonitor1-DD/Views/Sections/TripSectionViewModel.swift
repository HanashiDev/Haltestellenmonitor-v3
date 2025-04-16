//
//  TripSectionViewModel.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 26.10.23.
//

import Foundation
import SwiftUI

class TripSectionViewData {
    var nr: Int
    var start: Date
    var end: Date
    var name: String = ""
    var color: Color
    
    init(start: Date, end: Date, name: String, nr: Int, color: Color) {
        self.start = start
        self.end = end
        self.name = name
        self.nr = nr
        self.color = color
    }
}

class TripSectionViewModel: ObservableObject {
    @Published var route: Route
    
    init(route: Route) {
        self.route = route
    }
    
    func getTime() -> String {
        "\(route.getTimeDifference()) Min"
    }
    
    func getUmstiege() -> String {
        route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege"
    }
    
    func getDuration(_ partialRoute: PartialRoute) -> (Int, String) {
        if partialRoute.Mot.type == "Footpath" && partialRoute.hasNoTime(){
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
                
                while (routes[beforeIndex].getDuration() == 0 && beforeIndex > 0) {
                    let item =  routes[beforeIndex]
                    if item.Mot.type == "MobilityStairsUp" {
                        str += " | Treppe ↑"
                    } else if item.Mot.type == "MobilityStairsDown" {
                        str += " | Treppe ↓"
                    }
                    beforeIndex -= 1
                }
                
                while (routes[afterIndex].getDuration() == 0 && afterIndex <=  routes.count) {
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
    
    func getRouteColoredBarDifference(a: TripSectionViewData) -> Int {
        let start: Double = a.start.timeIntervalSince1970
        let end: Double = a.end.timeIntervalSince1970
        return Int((end - start) / 60)
    }
    
    func getRouteColoredBars()  -> [TripSectionViewData] {
        let time: CGFloat = CGFloat(route.getTimeDifference())
    
        var arr: [TripSectionViewData] = []
        var index = 0
        
        for i in 0..<route.PartialRoutes.count {
            let partialRoute = route.PartialRoutes[i]
            var before: TripSectionViewData? = arr.count >= 1 ? arr.last : nil
    
            // Wartezeit
            if(partialRoute.getStartTime() == nil || partialRoute.getEndTime() == nil) {
                if(getDuration(partialRoute).0 == 0) {
                    continue
                }
                
                 guard let beforeSection = before  else {
                    continue
                }
         
                var date = beforeSection.end.addingTimeInterval(TimeInterval(Double(getDuration(partialRoute).0) * 60.0))
                index = index + 1
                arr.append(TripSectionViewData(start: beforeSection.end, end: date, name: "🕒", nr: index, color: Color.gray))
                continue
            }
            let start = partialRoute.getStartTime() ?? Date()
            let end = partialRoute.getEndTime() ?? Date()
            
            index = index + 1
            let newEleemnt = TripSectionViewData(start:start, end: end, name: partialRoute.getNameShort(), nr: index, color: partialRoute.getColor())
            
            // LAufzeiten
            if(before != nil ) {
                if(before!.end != newEleemnt.start) {
                    index = index + 1
                    arr.append(TripSectionViewData(start: before!.end, end: newEleemnt.start, name: "🚶‍➡️", nr: index, color: Color.gray))
                }
            }
            
            // Add current element
            if(newEleemnt.start != newEleemnt.end) {
                arr.append(newEleemnt)
            }
        }
        return arr
    }
}
