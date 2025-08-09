//
//  PartialRouteRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

private var timeFrameWidth: CGFloat = 60

struct TripLegRow: View {
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
            TripLegRow(tripLeg: tripTmp.journeys.first!.legs.first!)
                .previewLayout(.fixed(width: 500, height: 100))
                .padding()
        }  .padding()
    }
 }

struct InterTripLegWaitingRow: View {
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

struct AfterTripLegFootpathRow: View {
    var duration: Int
    let text: String = "Fußweg"

    var body: some View {
        HStack {
            Text(Image(systemName: "figure.walk"))
                .frame(width: timeFrameWidth)
                .offset(CGSize(width: 13, height: 0))
                .accessibilityHidden(true)

            Text("\(duration) min \(text)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(CGSize(width: 22, height: 0))

        }
        .foregroundColor(.gray)
        .font(.subheadline.monospacedDigit())
        .padding(.leading, -47.5) // fixes horizontal line below row
        .accessibilityElement(children: .combine)
    }
}
