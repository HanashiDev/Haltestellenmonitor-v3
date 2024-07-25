//
//  SingleTripRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var callAtStop: CallAtStop
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(callAtStop.StopPointName)
                    .font(.headline)
                .lineLimit(1)
                Spacer()
                if (callAtStop.EstimatedBay != nil || callAtStop.PlannedBay != nil) {
                    Text(callAtStop.getPlatForm())
                        .font(.footnote)
                }
            }
            HStack {
                Text("\(callAtStop.getScheduledTime()) Uhr")
                if (callAtStop.getTimeDifference() > 0) {
                    Text("+\(callAtStop.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (callAtStop.getTimeDifference() < 0) {
                    Text("\(callAtStop.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text("\(callAtStop.getRealTime()) Uhr")
            }
            .font(.subheadline)
        }
    }
}

/*struct SingleTripRow_Previews: PreviewProvider {
    static var previews: some View {
        SingleTripRow(tripStop: singleTripTmp.Stops[0])
    }
}*/
