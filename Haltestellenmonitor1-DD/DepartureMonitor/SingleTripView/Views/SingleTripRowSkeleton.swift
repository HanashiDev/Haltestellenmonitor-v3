//
//  SingleTripRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct SingleTripRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Hauptbahnhof")
                    .font(.headline)
                    .skeleton()
                Spacer()
                Text("Steig 1")
                    .font(.footnote)
                    .skeleton()
            }
            HStack {
                Text("10:10 Uhr")
                    .skeleton()
                Spacer()
                Text("10:10 Uhr")
                    .skeleton()
            }
            .font(.subheadline)
        }
    }
}
