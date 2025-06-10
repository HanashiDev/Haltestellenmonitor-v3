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
        VStack(alignment: .leading) {
            Text(context.attributes.name)
                .font(.headline)
                .lineLimit(1)
            HStack {
                Text(context.attributes.getIcon())
                VStack(alignment: .leading) {
                    Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                        .lineLimit(1)
                    if context.state.done {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.green)
                    } else {
                        HStack {
                            Text("in \(context.state.getIn()) min")
                            Text("(\(context.state.getRealTime()))")
                        }
                    }
                }
            }
            .font(.subheadline)
        }
    }

}
