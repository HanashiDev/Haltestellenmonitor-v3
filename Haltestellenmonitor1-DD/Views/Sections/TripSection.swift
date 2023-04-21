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
                Text("ab \(route.getStartTimeString()) Uhr")
                    .font(.subheadline)
                Spacer()
                Text("an \(route.getEndTimeString()) Uhr")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text(route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege")
                    .font(.subheadline)
                Spacer()
                Text(route.getTimeDifference() == 1 ? "1 Minute" : "\(route.getTimeDifference()) Minuten")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
            }
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
    }
}

struct TripSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TripSection(route: tripTmp.Routes[0])
        }
    }
}
