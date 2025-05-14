//
//  StopRowView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct StopRow: View {
    @EnvironmentObject var favoriteStops: FavoriteStop
    var stop: Stop

    var body: some View {
        HStack(alignment: .center) {
            if favoriteStops.isFavorite(stopID: stop.stopID) {
                Image(systemName: "star.fill")
                    .accessibilityValue("Favorit")
            }
            VStack(alignment: .leading) {
                Text(stop.name)
                    .font(.headline)
                HStack {
                    Text(stop.place)
                        .font(.subheadline)
                    Spacer()
                    if stop.distance != nil {
                        Text("\(stop.getDistance()) m")
                            .font(.subheadline)
                            .accessibilityLabel("Entfernung \(stop.getDistance()) m")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct StopRowView_Previews: PreviewProvider {
    static var previews: some View {
        StopRow(stop: stops[0]).environmentObject(FavoriteStop())
    }
}
