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
            HStack {
                Text(context.attributes.getIcon())
                Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text("\(context.state.getScheduledTime()) Uhr")
                    .font(.footnote)
                    .opacity(0.6)
                if context.state.getTimeDifference() > 0 {
                    if #available(iOS 17.0, *) {
                        Text("+\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                            .opacity(0.8)
                            .contentTransition(.numericText(value: Double(context.state.getTimeDifference())))
                    } else {
                        Text("+\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                            .opacity(0.8)
                            .contentTransition(.numericText())
                    }
                } else if context.state.getTimeDifference() < 0 {
                    if #available(iOS 17.0, *) {
                        Text("\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.green)
                            .opacity(0.8)
                            .contentTransition(.numericText(value: Double(context.state.getTimeDifference())))
                    } else {
                        Text("\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.green)
                            .opacity(0.8)
                            .contentTransition(.numericText())
                    }
                }
            }
            Spacer()

            HStack {
                Text(context.attributes.name)
                    .lineLimit(1)
                Spacer()
                    Text("\(context.state.getRealTime()) Uhr")
                        .contentTransition(.numericText())
            }
            .font(.subheadline)
            ProgressView(value: context.attributes.getProgress(context.state))
                .progressViewStyle(.linear)
                .tint(.blue)
                .background(.white)

            HStack {
                Spacer()
                if context.state.done {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    if #available(iOS 17.0, *) {
                        Text("in \(context.state.getIn()) min")
                            .contentTransition(.numericText(value: Double(context.state.getIn())))
                    } else {
                        Text("in \(context.state.getIn()) min")
                            .contentTransition(.numericText(countsDown: true))
                    }
                }
                Spacer()
            }
            .frame(height: 15) // prevent shifting when done
        }
    }
}

@available(iOS 18.0, *)
#Preview("Banner & Watch", as: .content, using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}
