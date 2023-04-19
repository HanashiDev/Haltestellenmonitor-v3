//
//  PartialRouteRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct PartialRouteRow: View {
    var partialRoute: PartialRoute

    var body: some View {
        HStack {
            Image(systemName: partialRoute.getIcon())
            VStack(alignment: .leading) {
                Text(partialRoute.getName())
                    .font(.headline)
                if (partialRoute.getStartTimeString() != nil || partialRoute.getEndTimeString() != nil) {
                    HStack {
                        if (partialRoute.getStartTimeString() != nil) {
                            Text("\(partialRoute.getStartTimeString()!) Uhr")
                                .font(.subheadline)
                        }
                        Spacer()
                        if (partialRoute.getEndTimeString() != nil) {
                            Text("\(partialRoute.getEndTimeString()!) Uhr")
                                .font(.subheadline)
                        }
                    }}
            }
        }
    }
}

struct PartialRouteRow_Previews: PreviewProvider {
    static var previews: some View {
        PartialRouteRow(partialRoute: tripTmp.Routes[0].PartialRoutes[0])
    }
}
