//
//  TripSectionViewModel.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 26.10.23.
//

import Foundation


class TripSectionViewModel: ObservableObject {
    @Published var route: Route
    
    init(route: Route) {
        self.route = route
    }
    
    func getTime() -> String {
      //"\(route.getTimeDifference()) Min"
        return ""
    }
    
    func getUmstiege() -> String {
        route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege"
    }
    
    func getDuration(_ partialRoute: PartialRoute) -> (Int, String) {
        return (0, "")
        /*if partialRoute.Mot.type == "Footpath" && partialRoute.hasNoTime(){
            return  getWaitingTime(partialRoute, routes: route.PartialRoutes)
        }
        return (partialRoute.getDuration(), "")*/
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
                
                /*while (routes[beforeIndex].getDuration() == 0 && beforeIndex > 0) {
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
                
                value = difference ?? 0*/
            }
        }
        
        if value < 0 {
            return (0, str)
        }
        return (value, str)
    }
}
