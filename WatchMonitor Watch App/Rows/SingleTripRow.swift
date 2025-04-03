//
//  SingleTripRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var stopSequenceItem: StopSequenceItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(stopSequenceItem.name)
                .lineLimit(1)
            HStack {
                Text(stopSequenceItem.getScheduledTime())
                if (stopSequenceItem.getTimeDifference() > 0) {
                    Text("+\(stopSequenceItem.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (stopSequenceItem.getTimeDifference() < 0) {
                    Text("\(stopSequenceItem.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(stopSequenceItem.getRealTime())
            }
            .font(.footnote)
            if (stopSequenceItem.properties.platfromName != nil || stopSequenceItem.properties.plannedPlatformName != nil) {
                Text(stopSequenceItem.getPlatform())
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
