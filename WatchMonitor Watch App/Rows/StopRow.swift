//
//  StopRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct StopRow: View {
    @EnvironmentObject var favoriteStops: FavoriteStop
    var stop: Stop
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stop.name)
                    .lineLimit(1)
                Spacer()
                if (favoriteStops.isFavorite(stopID: stop.stopID)) {
                    Image(systemName: "star.fill")
                        .font(.footnote)
                        .foregroundColor(Color.yellow)
                }
            }
            HStack {
                Text(stop.place)
                .lineLimit(1)
                Spacer()
                if (stop.distance != nil) {
                    Text("\(stop.getDistance()) m")
                        .lineLimit(1)
                }
            }
            .font(.footnote)
        }
    }
}

struct StopRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StopRow(stop: stops[0])
                .environmentObject(FavoriteStop())
        }
    }
}
