//
//  LiveActivityBannerSmall.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 10.06.25.
//

import SwiftUI
import WidgetKit

/// use this for the AW SmartStack
struct LiveActivityBannerSmall: View {
    let context: ActivityViewContext<TripAttributes>

    var body: some View {
        HStack {
            Text(context.attributes.getIcon())
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(
                    "\(context.attributes.publishedLineName) \(context.attributes.destinationText)"
                )
                .font(.headline)
                .lineLimit(1)
                if context.state.done {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    HStack {
                        Text("in \(context.state.getIn()) min")
                        Text("(\(context.state.getRealTime()))")
                    }
                    Text(context.attributes.name)
                        .font(.footnote)
                        .lineLimit(1)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
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
