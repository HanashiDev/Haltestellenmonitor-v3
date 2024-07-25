//
//  SingleTripRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var callAtStop: CallAtStop
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(callAtStop.StopPointName)
                .lineLimit(1)
            HStack {
                Text(callAtStop.getScheduledTime())
                if (callAtStop.getTimeDifference() > 0) {
                    Text("+\(callAtStop.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (callAtStop.getTimeDifference() < 0) {
                    Text("\(callAtStop.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(callAtStop.getRealTime())
            }
            .font(.footnote)
            if (callAtStop.EstimatedBay != nil || callAtStop.PlannedBay != nil) {
                Text(callAtStop.getPlatForm())
                    .font(.footnote)
            }
        }
    }
}

/*struct SingleTripRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SingleTripRow(tripStop: singleTripTmp.Stops[0])
        }
    }
}*/
