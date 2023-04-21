//
//  SingleTripRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var tripStop: TripStop
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(tripStop.Name)
                .font(.headline)
                .lineLimit(1)
            HStack {
                Text("\(tripStop.getTime()) Uhr")
                if (tripStop.getTimeDifference() > 0) {
                    Text("+\(tripStop.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (tripStop.getTimeDifference() < 0) {
                    Text("\(tripStop.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text("\(tripStop.getRealTime()) Uhr")
            }
            .font(.subheadline)
        }
    }
}

struct SingleTripRow_Previews: PreviewProvider {
    static var previews: some View {
        SingleTripRow(tripStop: singleTripTmp.Stops[0])
    }
}
