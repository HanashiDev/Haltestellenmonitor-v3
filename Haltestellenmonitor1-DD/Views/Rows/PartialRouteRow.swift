//
//  PartialRouteRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

private var timeFrameWidth: CGFloat = 60

struct PartialRouteRow: View {
    var partialRoute: PartialRoute

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if partialRoute.getStartTimeString() != nil {
                    Text("\(partialRoute.getStartTimeString()!)")
                        .frame(width: timeFrameWidth, alignment: .leading)
                        .foregroundColor(.gray)
                        .font(.subheadline.monospacedDigit())
                        .accessibilityLabel("Abfahrt \(partialRoute.getStartTimeString()!)")
                        .accessibilitySortPriority(4)
                }
                HStack {
                    partialRoute.getIconText()
                        .frame(width: 20.0, alignment: .center)
                        .accessibilityLabel(partialRoute.getAccessibilityLabel())
                        .accessibilitySortPriority(5)

                    Text(partialRoute.getName())
                        .font(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilitySortPriority(5)
                }
                Spacer()
                Text(partialRoute.getFirstPlatform() ?? "")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(width: 45, alignment: .trailing)
                    .accessibilitySortPriority(4)

            }
            HStack {
                if partialRoute.getStartTimeString() != nil || partialRoute.getEndTimeString() != nil {
                    Text("|")
                        .frame(width: timeFrameWidth, alignment: .leading)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.leading, 18.5)
                        .accessibilityHidden(true)

                    Spacer()

                }
            }
            HStack {
                if partialRoute.getEndTimeString() != nil {
                    Text("\(partialRoute.getEndTimeString()!)")
                        .frame(width: timeFrameWidth, alignment: .leading)
                        .foregroundColor(.gray)
                        .font(.subheadline.monospacedDigit())
                        .accessibilitySortPriority(2)
                        .accessibilityLabel("Ankunft \(partialRoute.getEndTimeString()!)")

                }
                if partialRoute.getEndTimeString() != nil {
                    Text(partialRoute.getLastStation() ?? "")
                        .font(.subheadline)
                        .accessibilityLabel("Bis \(partialRoute.getLastStation() ?? "")")
                        .accessibilityHint("Ausstieg")
                        .accessibilitySortPriority(3)
                }
                Spacer()

                Text(partialRoute.getLastPlatform() ?? "")
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
            PartialRouteRow(partialRoute: tripTmp.Routes[0].PartialRoutes[0])
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
