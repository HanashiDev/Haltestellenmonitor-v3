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
                PartialRouteRow(partialRoute: partialRoute)
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
