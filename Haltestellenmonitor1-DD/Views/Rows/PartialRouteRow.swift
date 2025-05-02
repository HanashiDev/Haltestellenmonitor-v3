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
        HStack(spacing: 0) {

            VStack {
                if partialRoute.getStartTimeString() != nil {
                    Text("\(partialRoute.getStartTimeString()!)")
                }

                if partialRoute.getStartTimeString() != nil || partialRoute.getEndTimeString() != nil {
                    Text("|")
                }

                if partialRoute.getEndTimeString() != nil {
                    Text("\(partialRoute.getEndTimeString()!)")
                }
            }.frame(width: timeFrameWidth)
                .foregroundColor(.gray)
                .font(.subheadline)

            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Text(partialRoute.getIcon())
                        .frame(width: 20.0, alignment: .center)

                    Text(partialRoute.getName())
                        .font(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("")

                if partialRoute.getEndTimeString() != nil {
                    Text(partialRoute.getLastStation() ?? "")
                }
            }
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .font(.subheadline)

            VStack(alignment: .trailing) {
                Text(partialRoute.getFirstPlatform() ?? "")  .foregroundColor(.gray)
                
                Text("")
                
                Text(partialRoute.getLastPlatform() ?? "")  .foregroundColor(.gray)
            }
            .frame(width: 70)
            .foregroundColor(.gray)
            .lineLimit(1)
            .font(.footnote)
        }
        .padding(.leading, -35).padding(.trailing, -15)
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
        HStack(spacing: 0) {
            Text("︙")
                .frame(width: timeFrameWidth)

            Text("\(time) min \(text)")
                .frame(maxWidth: .infinity, alignment: .leading)

        }
        .foregroundColor(.gray)
        .font(.subheadline)
        .padding(.leading, -35).padding(.trailing, -15)
    }
}
