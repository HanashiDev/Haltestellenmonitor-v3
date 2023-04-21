//
//  RegularStopRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct RegularStopRow: View {
    var regularStop: RegularStop
    var isFirst: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(regularStop.Name)
            HStack {
                Text("\(isFirst ? regularStop.getDepartureTime() :  regularStop.getArrivalTime()) Uhr")
                if (isFirst) {
                    if (regularStop.getTimeDifferenceDeparture() > 0) {
                        Text("+\(regularStop.getTimeDifferenceDeparture())")
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                    } else if (regularStop.getTimeDifferenceDeparture() < 0) {
                        Text("\(regularStop.getTimeDifferenceDeparture())")
                            .font(.subheadline)
                            .foregroundColor(Color.green)
                    }
                } else {
                    if (regularStop.getTimeDifference() > 0) {
                        Text("+\(regularStop.getTimeDifference())")
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                    } else if (regularStop.getTimeDifference() < 0) {
                        Text("\(regularStop.getTimeDifference())")
                            .font(.subheadline)
                            .foregroundColor(Color.green)
                    }
                }
                Spacer()
                Text("\(isFirst ? regularStop.getRealDepartureTime() : regularStop.getRealArrivalTime()) Uhr")
            }
        }
        .font(.subheadline)
    }
}

struct RegularStopRow_Previews: PreviewProvider {
    static var previews: some View {
        RegularStopRow(regularStop: tripTmp.Routes[0].PartialRoutes[0].RegularStops![0], isFirst: true)
    }
}
