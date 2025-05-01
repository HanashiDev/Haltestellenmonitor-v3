//
//  SingleTripRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct SingleTripRow: View {
    var stopSequenceItem: StopSequenceItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stopSequenceItem.name)
                    .font(.headline)
                .lineLimit(1)
                Spacer()
                if stopSequenceItem.properties.platfromName != nil || stopSequenceItem.properties.plannedPlatformName != nil {
                    Text(stopSequenceItem.getPlatform())
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                }
            }
            HStack {
                Text("\(stopSequenceItem.getScheduledTime()) Uhr")
                if stopSequenceItem.getTimeDifference() > 0 {
                    Text("+\(stopSequenceItem.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if stopSequenceItem.getTimeDifference() < 0 {
                    Text("\(stopSequenceItem.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text("\(stopSequenceItem.getRealTime()) Uhr")
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
