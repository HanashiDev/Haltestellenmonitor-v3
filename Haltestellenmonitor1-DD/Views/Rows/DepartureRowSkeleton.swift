//
//  DepartureRowSkeleton.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 06.05.25.
//

import SwiftUI

struct DepartureRowSkeleton: View {
    var body: some View {
        HStack(alignment: .center) {
            Text(getIconStandard(motType: .Default))
                .skeleton(Circle())

            Spacer() // prevent shifiting if delayed
            VStack(alignment: .leading) {
                Text("Hauptbahnhof")
                    .font(.headline)
                    .skeleton()

                HStack {
                    Text("10:10 Uhr")
                        .skeleton()

                    Spacer()
                    Text("10:20 Uhr")
                        .skeleton()

                }
                .font(.subheadline)

                HStack {
                    Text("Steig 1")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .skeleton()

                    Spacer()
                    Text("in 4 min")
                        .skeleton()
                }
                .font(.subheadline)

            }
        }
    }
}
