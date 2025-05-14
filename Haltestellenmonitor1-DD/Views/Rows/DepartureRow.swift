//
//  DepartureRowView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct DepartureRow: View {
    var stopEvent: StopEvent

    @ObservedObject private var departureBinding: DepartureBinding

    init(stopEvent: StopEvent) {
        self.stopEvent = stopEvent

        self.departureBinding = DepartureBinding(inMinute: stopEvent.getIn())
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(stopEvent.getIcon())
                .accessibilitySortPriority(2)
                .accessibilityLabel(stopEvent.getIconAccessabilityLabel())
            Spacer() // prevent shifiting if delayed
            VStack(alignment: .leading) {
                HStack {
                    Text(stopEvent.getName())
                        .font(.headline)
                        .lineLimit(1)
                        .accessibilitySortPriority(2)

                    if stopEvent.hasInfos() {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                            .accessibilityLabel("Mit zusätzlichen Hinweisen")
                            .accessibilitySortPriority(-1)
                    }
                }
                HStack {
                    Text("\(stopEvent.getScheduledTime()) Uhr")
                        .accessibilityLabel("Geplant: \(stopEvent.getScheduledTime()) Uhr")
                    if stopEvent.getTimeDifference() > 0 {
                        Text("+\(stopEvent.getTimeDifference())")
                            .foregroundColor(Color.red)
                            .accessibilityLabel("+\(stopEvent.getTimeDifference()) Minuten")
                    } else if stopEvent.getTimeDifference() < 0 {
                        Text("\(stopEvent.getTimeDifference())")
                            .foregroundColor(Color.green)
                            .accessibilityLabel("\(stopEvent.getTimeDifference()) Minuten")

                    }
                    Spacer()
                    Text("\(stopEvent.getEstimatedTime()) Uhr")
                        .accessibilityLabel("Erwartet: \(stopEvent.getEstimatedTime()) Uhr")

                }
                .font(.subheadline)

                HStack {
                    if stopEvent.location.properties?.platformName != nil || stopEvent.location.properties?.plannedPlatformName != nil {
                        Text(stopEvent.getPlatform())
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if stopEvent.isCancelled ?? false {
                        Text("Fahrt fällt aus")
                            .foregroundColor(Color.red)
                    } else {
                    Text("in \(departureBinding.inMinute) min")
                            .accessibilityLabel("Abfahrt in \(departureBinding.inMinute) min")
                            .accessibilitySortPriority(1)
                    }
                }
                .font(.subheadline)
            }
        }.accessibilityElement(children: .combine)
    }
}

/*struct DepartureRowView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureRow(departure: departureM.Departures[4])
    }
}*/
