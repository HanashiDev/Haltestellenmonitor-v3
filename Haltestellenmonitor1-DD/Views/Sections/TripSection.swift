//
//  TripSection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct TripSection: View {
    var vm: TripSectionViewModel
    
    var body: some View {
        // TODO: Steig bzw. Gleis überall einfügen
        Section {
            HStack {
                Text("\(vm.route.getStartTimeString()) Uhr")
                Image(systemName: "arrow.forward")
                Text("\(vm.route.getEndTimeString()) Uhr")
                
                Spacer()
                
                Text("| \(vm.getTime())")
                    .foregroundColor(.gray)
                
                if vm.route.Interchanges > 0 {
                    Text("| \(vm.getUmstiege())")
                        .foregroundColor(.gray)
                }
            }.font(.subheadline)
            
            DisclosureGroup {
                ForEach(vm.route.PartialRoutes, id: \.self) { partialRoute in
                    if partialRoute.RegularStops == nil {
                        if partialRoute.getDuration() == 0 {
                            let tup = vm.getDuration(partialRoute)
                            if tup.0 > 0 {
                                PartialRouteRowWaitingTime(time: tup.0, text: tup.1)
                            }
                        } else {
                            PartialRouteRow(partialRoute: partialRoute)
                        }
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
        label: { tripView() }
        }
    }
    
    @ViewBuilder
    func tripView() -> some View {
        let time: CGFloat = CGFloat(vm.route.getTimeDifference())

         GeometryReader { geo in
            HStack (spacing: 0) {
                
                ForEach(vm.getRouteColoredBars(), id: \.self.nr) { routeEntry in
                    let stopTime = vm.getRouteColoredBarDifference(a: routeEntry)
                    let width = (CGFloat(stopTime) / time) * geo.size.width
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(routeEntry.color)
                            .frame(width: width, height: 5)
                        Text(routeEntry.name)
                            .foregroundColor(.customGray)
                            .font(.footnote)
                            .frame(width: width, height: 15)
                    }.padding(0)
                }
            }.frame(width: geo.size.width)
        }
    }
}

/*struct TripSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TripSection(vm: TripSectionViewModel(route: tripTmp.Routes[0]))
        }
    }
}*/
