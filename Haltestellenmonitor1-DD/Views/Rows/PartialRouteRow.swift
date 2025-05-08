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
                }
                HStack {
                    Text(partialRoute.getIcon())
                        .frame(width: 20.0, alignment: .center)

                    Text(partialRoute.getName())
                        .font(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Text(partialRoute.getFirstPlatform() ?? "")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(width: 45, alignment: .trailing)

            }
            HStack {
                if partialRoute.getStartTimeString() != nil || partialRoute.getEndTimeString() != nil {
                    Text("|")
                        .frame(width: timeFrameWidth, alignment: .leading)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.leading, 18.5)

                    Spacer()

                }
            }
            HStack {
                if partialRoute.getEndTimeString() != nil {
                    Text("\(partialRoute.getEndTimeString()!)")
                        .frame(width: timeFrameWidth, alignment: .leading)
                        .foregroundColor(.gray)
                        .font(.subheadline.monospacedDigit())

                }
                if partialRoute.getEndTimeString() != nil {
                    Text(partialRoute.getLastStation() ?? "")
                        .font(.subheadline)
                }
                Spacer()

                Text(partialRoute.getLastPlatform() ?? "")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(width: 45, alignment: .trailing)

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

            Text("\(time) min \(text)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(CGSize(width: 22, height: 0))

        }
        .foregroundColor(.gray)
        .font(.subheadline.monospacedDigit())
        .padding(.leading, -47.5) // fixes horizontal line below row
    }
}
