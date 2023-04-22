//
//  SingleTripRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var tripStop: TripStop
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(tripStop.Name)
                .lineLimit(1)
            HStack {
                Text(tripStop.getTime())
                if (tripStop.getTimeDifference() > 0) {
                    Text("+\(tripStop.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (tripStop.getTimeDifference() < 0) {
                    Text("\(tripStop.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(tripStop.getRealTime())
            }
            .font(.footnote)
            if (tripStop.Platform != nil) {
                Text(tripStop.getPlatForm())
                    .font(.footnote)
            }
        }
    }
}

struct SingleTripRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SingleTripRow(tripStop: singleTripTmp.Stops[0])
        }
    }
}
