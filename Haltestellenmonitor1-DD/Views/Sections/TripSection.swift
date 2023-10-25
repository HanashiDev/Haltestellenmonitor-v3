//
//  TripSection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct TripSection: View {
    var route: Route
    
    var body: some View {
        // TODO: Steig bzw. Gleis überall einfügen
        Section {
            HStack {
                Text("\(route.getStartTimeString()) Uhr")
                Image(systemName: "arrow.forward")
                Text("\(route.getEndTimeString()) Uhr")
                Spacer()
                Text("| \(getTime())")
                    .foregroundColor(.gray)
                if route.Interchanges > 0 {
                    Text("| \(getUmstiege())")
                        .foregroundColor(.gray)
                }
            }.font(.subheadline)
            
            DisclosureGroup {
                ForEach(route.PartialRoutes, id: \.self) { partialRoute in
                    if (partialRoute.RegularStops == nil) {
                        PartialRouteRow(partialRoute: partialRoute)
                    } else {
                        DisclosureGroup {
                            ForEach (partialRoute.RegularStops ?? [], id: \.self) { regularStop in
                                ZStack {
                                    NavigationLink(value: regularStop.getStop() ?? stops[0]) {
                                        EmptyView()
                                    }
                                    .opacity(0.0)
                                    .buttonStyle(.plain)
                                    
                                    RegularStopRow(regularStop: regularStop, isFirst: partialRoute.RegularStops?.first?.DataId == regularStop.DataId)
                                }
                            }
                        } label: {
                            PartialRouteRow(partialRoute: partialRoute)
                        }
                    }
                }
            }
        label: { tripView()
        }
        }
    }
    
    @ViewBuilder
    func tripView() -> some View {
        let time: CGFloat = CGFloat(route.getTimeDifference())
        
        GeometryReader { geo in
            HStack (spacing: 0) {
                ForEach(route.PartialRoutes, id: \.self) { partialRoute in
                    let stopTime = getDuration(partialRoute)
                    let currentTime = CGFloat(stopTime) / time
                    let width = currentTime * geo.size.width
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(partialRoute.getColor())
                            .frame(width: width, height: 5)
                        Text(partialRoute.getNameShort())
                            .foregroundColor(.customGray)
                    }
                }
            }.frame(width: geo.size.width)
        }
    }
    
    func getDuration(_ partialRoute: PartialRoute) -> Int {
        if partialRoute.Mot.type == "Footpath" && partialRoute.hasNoTime(){
            return  Int(getWaitingTime(partialRoute))
        }
        return partialRoute.getDuration()
    }
    
    func getWaitingTime(_ e: PartialRoute) -> Int {
        var value = 0
        route.PartialRoutes.forEach { f in
            if e == f {
                guard let index = route.PartialRoutes.firstIndex(of: e) else { return }
                if index - 1 < 0 || index + 1 >= route.PartialRoutes.count {
                    return
                }
                
                let defaultDate = Date()
                var date1 = defaultDate
                var date2  = defaultDate
                var beforeIndex = index - 1
                var afterIndex = index + 1
                
                while (route.PartialRoutes[beforeIndex].getDuration() == 0 && beforeIndex > 0) {
                    beforeIndex -= 1
                }
                
                while (route.PartialRoutes[afterIndex].getDuration() == 0 && afterIndex <=  route.PartialRoutes.count) {
                    afterIndex += 1
                }
                
                date1 = route.PartialRoutes[beforeIndex].getEndTime() ?? defaultDate
                date2 = route.PartialRoutes[afterIndex].getStartTime() ?? defaultDate
                
                let difference = Calendar.current.dateComponents([.minute], from: date1, to: date2).minute
                
                value = difference ?? 0
            }
        }
        
        if value < 0 {
            return 0
        }
        return value
    }

    func getTime() -> String {
      "\(route.getTimeDifference()) Min"
    }
    
    func getUmstiege() -> String {
        route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege"
    }
    
}

struct TripSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TripSection(route: tripTmp.Routes[0])
        }
    }
}
