//
//  PartialRouteRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

private var timeFrameWidth: CGFloat = 60

struct PartialRouteRow: View {
    var tripLeg: TripLeg

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(tripLeg.getStartTimeString())")
                    .frame(width: timeFrameWidth, alignment: .leading)
                    .foregroundColor(.gray)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityLabel("Abfahrt \(tripLeg.getStartTimeString())")
                    .accessibilitySortPriority(4)
                HStack {
                    tripLeg.getIconText()
                        .frame(width: 20.0, alignment: .center)
                        .accessibilityLabel(tripLeg.getAccessibilityLabel())
                        .accessibilitySortPriority(5)

                    Text(tripLeg.getName())
                        .font(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilitySortPriority(5)
                }
                Spacer()
                Text(tripLeg.getFirstPlatform())
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(width: 45, alignment: .trailing)
                    .accessibilitySortPriority(4)

            }
            HStack {
                Text("|")
                    .frame(width: timeFrameWidth, alignment: .leading)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.leading, 18.5)
                    .accessibilityHidden(true)

                Spacer()
            }
            HStack {
                Text("\(tripLeg.getEndTimeString())")
                    .frame(width: timeFrameWidth, alignment: .leading)
                    .foregroundColor(.gray)
                    .font(.subheadline.monospacedDigit())
                    .accessibilitySortPriority(2)
                    .accessibilityLabel("Ankunft \(tripLeg.getEndTimeString())")

                Text(tripLeg.getLastStopName())
                    .font(.subheadline)
                    .accessibilityLabel("Bis \(tripLeg.getLastStopName())")
                    .accessibilityHint("Ausstieg")
                    .accessibilitySortPriority(3)
                Spacer()

                Text(tripLeg.getLastPlatform() ?? "")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(width: 45, alignment: .trailing)
                    .accessibilitySortPriority(2)

            }
        }.padding(.leading, -25)
    }
}

 struct PartialRouteRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PartialRouteRow(tripLeg: TripLeg(duration: 60,
                                             origin: TripLeg.TripOrigin(id: "123", name: "Hauptbahnhof", coord: [1.0, 2.0], niveau: 0, departureTimePlanned: "2025-03-26T06:00:00Z", departureTimeEstimated: "2025-03-26T06:00:00Z", disassebledName: ""),
                                             destination: TripLeg.TripDestination(id: "456", name: "Postplatz", coord: [3.0, 4.0], niveau: 0, arrivalTimePlanned: "2025-03-26T06:05:00Z", arrivalTimeEstimated: "2025-03-26T06:06:00Z", disassebledName: ""),
                                             transportation: TripLeg.TripTransportation(id: "", number: "7", product: Product(name: "Tram", iconId: 4), properties: T_Properties(trainName: "", trainType: "", trainNumber: "7", tripCode: 0, globalId: "", specialFares: "")),
                                    stopSequence: [StopSequenceItem(id: "xyz", name: "Hauptbahnhof", parent: Location(name: "Hauptbahnhof", type: ""), properties: StopSequenceItem.properties(platfromName: "1"))],
                                             infos: [], coords: [], pathDescription: TripLeg.PathDescription(name: "TODO", coord: []), interchange: TripLeg.Interchange(desc: "TODO", coords: []), footPathInfo: [], footPathInfoRedundant: true))
                .previewLayout(.fixed(width: 500, height: 100))
                .padding()
        }  .padding()
    }
 }

struct PartialRouteRowWaitingTime: View {
    var time: Int
    var text: String = "Wartezeit"

    var body: some View {
        HStack {
            Text("︙")
                .frame(width: timeFrameWidth)
                .offset(CGSize(width: 13, height: 0))
                .accessibilityHidden(true)

            Text("\(time) min \(text)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(CGSize(width: 22, height: 0))

        }
        .foregroundColor(.gray)
        .font(.subheadline.monospacedDigit())
        .padding(.leading, -47.5) // fixes horizontal line below row
        .accessibilityElement(children: .combine)
    }
}
