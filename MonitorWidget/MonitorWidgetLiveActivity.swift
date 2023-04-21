//
//  MonitorWidgetLiveActivity.swift
//  MonitorWidget
//
//  Created by Peter Lohse on 19.04.23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MonitorWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading) {
                Text(context.attributes.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack {
                    Image(systemName: context.attributes.getIcon())
                    VStack {
                        HStack {
                            Text(context.attributes.line)
                                .lineLimit(1)
                            Spacer()
                            if (context.state.done) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(Color.green)
                            } else {
                                Text("in \(context.state.getIn()) min")
                            }
                        }
                        HStack {
                            Text("\(context.state.getScheduledTime()) Uhr")
                            if (context.state.getTimeDifference() > 0) {
                                Text("+\(context.state.getTimeDifference())")
                                    .font(.subheadline)
                                    .foregroundColor(Color.red)
                            } else if (context.state.getTimeDifference() < 0) {
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
            }
            .foregroundColor(Color.black)
            .padding()
            .activityBackgroundTint(Color("NotificationBackground"))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("\(context.state.getScheduledTime()) Uhr")
                        if (context.state.getTimeDifference() > 0) {
                            Text("+\(context.state.getTimeDifference())")
                                .font(.subheadline)
                                .foregroundColor(Color.red)
                        } else if (context.state.getTimeDifference() < 0) {
                            Text("\(context.state.getTimeDifference())")
                                .font(.subheadline)
                                .foregroundColor(Color.green)
                        }
                    }
                    .padding(.horizontal)
                    .font(.subheadline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("\(context.state.getRealTime()) Uhr")
                        if context.state.done {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.green)
                        } else {
                            Text("in \(context.state.getIn()) min")
                        }
                    }
                    .padding(.horizontal)
                    .font(.subheadline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "location")
                            Text(context.attributes.name)
                        }
                        .padding(.bottom, 1.0)
                        HStack {
                            Image(systemName: context.attributes.getIcon())
                            Text(context.attributes.line)
                                .lineLimit(1)
                        }
                    }
                    .font(.subheadline)
                }
            } compactLeading: {
                Text(context.attributes.line)
                    .font(.subheadline)
                    .lineLimit(1)
            } compactTrailing: {
                if context.state.done {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    Text("in \(context.state.getIn()) min")
                        .font(.subheadline)
                }
            } minimal: {
                if (context.state.done) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    Text("\(context.state.getIn())")
                }
            }
            // TODO: Deep Link
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct MonitorWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = TripAttributes(name: "Pirnaischer Platz", line: "4 Laubegast", type: "Tram")
    static let contentState = TripAttributes.ContentState(time: "/Date(1681824120000-0000)/", realTime: "/Date(1681825120000-0000)/", done: true)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .preferredColorScheme(.dark)
            .previewDisplayName("Notification")
    }
}
