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
            Text(partialRoute.getIcon())
            VStack(alignment: .leading) {
                Text(partialRoute.getName())
                    .font(.headline)
                if (partialRoute.getStartTimeString() != nil || partialRoute.getEndTimeString() != nil) {
                    HStack {
                        Text("\(partialRoute.getStartTimeString()!) Uhr")
                        Spacer()
                        Text("\(partialRoute.getEndTimeString()!) Uhr")
                    }
                    .font(.subheadline)
                }
                if (partialRoute.getFirstStation() != nil && partialRoute.getLastStation() != nil) {
                    HStack {
                        Text(partialRoute.getFirstStation() ?? "")
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "arrow.right")
                        Spacer()
                        Text(partialRoute.getLastStation() ?? "")
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }
                if (partialRoute.getFirstPlatform() != nil || partialRoute.getLastPlatform() != nil) {
                    HStack {
                        if partialRoute.getFirstPlatform() != nil {
                            Text(partialRoute.getFirstPlatform() ?? "")
                        }
                        Spacer()
                        if partialRoute.getLastPlatform() != nil {
                            Text(partialRoute.getLastPlatform() ?? "")
                        }
                    }
                    .font(.footnote)
                }
            }
        }
    }
}

struct PartialRouteRow_Previews: PreviewProvider {
    static var previews: some View {
        PartialRouteRow(partialRoute: tripTmp.Routes[0].PartialRoutes[0])
    }
}
