//
//  LiveActivityBanner.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 10.06.25.
//

import SwiftUI
import WidgetKit

struct LiveActivityBanner: View {
    let context: ActivityViewContext<TripAttributes>

    var body: some View {
        VStack(alignment: .leading) {
            Text(context.attributes.name)
                .font(.headline)
                .lineLimit(1)
            HStack {
                Text(context.attributes.getIcon())
                VStack {
                    HStack {
                        Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                            .lineLimit(1)
                        Spacer()
                        if context.state.done {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.green)
                        } else {
                            Text("in \(context.state.getIn()) min")
                        }
                    }
                    HStack {
                        Text("\(context.state.getScheduledTime()) Uhr")
                        if context.state.getTimeDifference() > 0 {
                            Text("+\(context.state.getTimeDifference())")
                                .font(.subheadline)
                                .foregroundColor(Color.red)
                        } else if context.state.getTimeDifference() < 0 {
                            Text("\(context.state.getTimeDifference())")
                                .font(.subheadline)
                                .foregroundColor(Color.green)
                        }
                        Spacer()
                        Text("\(context.state.getRealTime()) Uhr")
                    }
                }
            }
            .font(.subheadline)
//            ProgressView(value: context.state.getProgress(), total: 100)
//                .progressViewStyle(.linear)
//                .tint(.yellow)
//                .background(.white)
        }
    }

}
