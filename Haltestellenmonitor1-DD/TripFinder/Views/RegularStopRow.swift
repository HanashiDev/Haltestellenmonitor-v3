//
//  RegularStopRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct RegularStopRow: View {
    var stop: StopSequenceItem
    var isFirst: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stop.name)
                    .accessibilityLabel("Haltestelle \(stop.name)")
                Spacer()
                if stop.getPlatform() != "" {
                    Text(stop.getPlatform())
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .accessibilitySortPriority(-1)
                }
            }
            HStack {
                Text("\(isFirst ? stop.getRealTime() :  stop.getArrivalTime()) Uhr")
                    .accessibilityLabel("Geplante \(isFirst ? "Abfahrt " + stop.getRealTime() :  "Ankunft " + stop.getArrivalTime()) Uhr")
                if isFirst {
                    if stop.getTimeDifference() > 0 {
                        Text("+\(stop.getTimeDifference())")
                            .foregroundColor(Color.red)
                            .accessibilityLabel("\(stop.getTimeDifference()) \(stop.getTimeDifference() == 1 ? "Minute" : "Minuten") Verspätung")
                    } else if stop.getTimeDifference() < 0 {
                        Text("\(stop.getTimeDifference())")
                            .foregroundColor(Color.green)
                            .accessibilityLabel("\(abs(stop.getTimeDifference())) \(stop.getTimeDifference() == -1 ? "Minute" : "Minuten") früher")
                    }
                } else {
                    if stop.getTimeDifferenceArrival() > 0 {
                        Text("+\(stop.getTimeDifferenceArrival())")
                            .foregroundColor(Color.red)
                            .accessibilityLabel("\(stop.getTimeDifferenceArrival()) \(stop.getTimeDifferenceArrival() == 1 ? "Minute" : "Minuten") Verspätung")
                    } else if stop.getTimeDifference() < 0 {
                        Text("\(stop.getTimeDifferenceArrival())")
                            .foregroundColor(Color.green)
                            .accessibilityLabel("\(abs(stop.getTimeDifferenceArrival())) \(stop.getTimeDifferenceArrival() == -1 ? "Minute" : "Minuten") früher")
                    }
                }
                Spacer()
                Text("\(isFirst ? stop.getRealTime() : stop.getRealArrivalTime()) Uhr")
                    .accessibilityLabel("Voraussichtliche \(isFirst ? "Abfahrt " + stop.getRealTime() :  "Ankunft " + stop.getRealArrivalTime()) Uhr")

            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

/*struct RegularStopRow_Previews: PreviewProvider {
    static var previews: some View {
        RegularStopRow(regularStop: tripTmp.Routes[0].PartialRoutes[0].RegularStops![0], isFirst: true)
    }
}*/
