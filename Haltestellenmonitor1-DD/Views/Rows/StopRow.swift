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
            if (favoriteStops.isFavorite(stopPointRef: stop.stopPointRef)) {
                Image(systemName: "star.fill")
            }
            VStack(alignment: .leading) {
                Text(stop.stopPointName)
                    .font(.headline)
                HStack {
                    Text(stop.locationName)
                        .font(.subheadline)
                    Spacer()
                    if (stop.distance != nil) {
                        Text("\(stop.getDistance()) m")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

struct StopRowView_Previews: PreviewProvider {
    static var previews: some View {
        StopRow(stop: stops[0]).environmentObject(FavoriteStop())
    }
}
