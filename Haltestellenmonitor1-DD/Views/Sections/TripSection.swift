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
        print("------")
        
        print(route.PartialRoutes.forEach({ e in
            let stopTime = e.getDuration()
            let currentTime = CGFloat(stopTime) / time
            print(currentTime)
        }))
        
        return GeometryReader { geo in
            HStack (spacing: 0) {
                ForEach(route.PartialRoutes, id: \.self) { partialRoute in
                    let stopTime = partialRoute.getDuration()
                    let currentTime = CGFloat(stopTime) / time
                    let width = currentTime * geo.size.width
                    
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(partialRoute.getColor())
                            .frame(width: width, height: 5)
                        Text(partialRoute.getNameShort())
                            .foregroundColor(.black.opacity(0.7)) // TODO: darkmode
                    }//.background(Color.purple)
                }
            }.frame(width: geo.size.width)
        }
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
