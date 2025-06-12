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
        getBody()
    }

    func getBody() -> some WidgetConfiguration {
        if #available(iOS 18.0, *) {
            return newBody
        } else {
            return oldBody
        }
    }

    var oldBody: some WidgetConfiguration {
        ActivityConfiguration(for: TripAttributes.self) { context in
            // Lock screen/banner UI
            LiveActivityBanner(context: context)
            .widgetURL(getWidgetUrl(context: context))
            .foregroundColor(Color.black)
            .padding()
            .activityBackgroundTint(Color("NotificationBackground"))
            .activitySystemActionForegroundColor(Color.black)
            .dynamicTypeSize(.medium ... .large)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
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
                            Text(context.attributes.getIcon())
                            Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                                .lineLimit(1)
                        }
                    }
                    .font(.subheadline)
                }
            } compactLeading: {
                Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
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
                if context.state.done {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    Text("\(context.state.getIn())")
                }
            }
            .widgetURL(getWidgetUrl(context: context))
            .keylineTint(Color.red)
        }
    }

    @available(iOSApplicationExtension 18.0, *)
    var newBody: some WidgetConfiguration {
        ActivityConfiguration(for: TripAttributes.self) { context in
            SupplementalMonitorWidgetLiveActivity(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
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
                    VStack(alignment: .center) {
                        HStack {
                            Text(context.attributes.getIcon())
                            Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                                .lineLimit(1)
                                .font(.title)
                        }
                        HStack {
                            Image(systemName: "location")
                            Text(context.attributes.name)
                        }
                        .padding(.bottom, 1.0)
                        // maybe insert progress bar here
                    }
                    .font(.subheadline)
                }
            } compactLeading: {
                Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
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
                if context.state.done {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                } else {
                    Text("\(context.state.getIn())")
                }
            }
            .widgetURL(getWidgetUrl(context: context))
            .keylineTint(Color.red)
        }
        .supplementalActivityFamilies([.small, .medium])
    }

    func getWidgetUrl(context: ActivityViewContext<TripAttributes>) -> URL? {
        let str = "widget://trip/\(context.attributes.stopID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.lineRef.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.directionRef.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.timetabledTime.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!))"

        return URL(string: str)
    }
}

// additional styles for watch

@available(iOS 18.0, *)
struct SupplementalMonitorWidgetLiveActivity: View {
    @Environment(\.activityFamily) var activityFamily
    var context: ActivityViewContext<TripAttributes>

    var body: some View {
        switch activityFamily {
        case .small:
            // Watch Smart Stack
            LiveActivityBannerSmall(context: context)
                .widgetURL(getWidgetUrl(context: context))
                .foregroundColor(Color.black)
                .padding()
                .activityBackgroundTint(Color("NotificationBackground"))
                .activitySystemActionForegroundColor(Color.black)

        case .medium:
            // Lock screen/Banner
            LiveActivityBanner(context: context)
                .widgetURL(getWidgetUrl(context: context))
                .foregroundColor(Color.black)
                .padding()
                .background(Color("NotificationBackground")) // helps for Preview
                .activityBackgroundTint(Color("NotificationBackground"))
                .activitySystemActionForegroundColor(Color.black)
                .dynamicTypeSize(.medium ... .large)
        @unknown default:
            Text("Unsupported")
        }
    }

    func getWidgetUrl(context: ActivityViewContext<TripAttributes>) -> URL? {
        let str = "widget://trip/\(context.attributes.stopID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.lineRef.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.directionRef.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\(context.attributes.timetabledTime.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!))"

        return URL(string: str)
    }
}

// for the previews, set non-changing properties
extension TripAttributes {
    static var preview: TripAttributes {
        TripAttributes(name: "Pirnaischer Platz", icon: "🚊", stopID: "300001", lineRef: "10000", timetabledTime: "2025-03-10T17:54:00Z", directionRef: "1", publishedLineName: "4", destinationText: "Laubegast", startTime: Date().addingTimeInterval(-600))
    }
}

// add some ContentStates for previews
extension TripAttributes.ContentState {
    static var initial: TripAttributes.ContentState {
        TripAttributes.ContentState(timetabledTime: getISO8601DateString(date: Date().addingTimeInterval(180)), estimatedTime: getISO8601DateString(date: Date().addingTimeInterval(600)), done: false)
    }

    static var in_progress: TripAttributes.ContentState {
        TripAttributes.ContentState(timetabledTime: getISO8601DateString(date: Date().addingTimeInterval(180)), estimatedTime: getISO8601DateString(date: Date().addingTimeInterval(300)), done: false)
    }

    static var complete: TripAttributes.ContentState {
        TripAttributes.ContentState(timetabledTime: getISO8601DateString(), estimatedTime: getISO8601DateString(), done: true)
    }
}

@available(iOS 18.0, *)
#Preview("Island minimal", as: .dynamicIsland(.minimal), using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}

@available(iOS 18.0, *)
#Preview("Island compact", as: .dynamicIsland(.compact), using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}

@available(iOS 18.0, *)
#Preview("Island expanded", as: .dynamicIsland(.expanded), using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}

@available(iOS 18.0, *)
#Preview("Banner & Watch", as: .content, using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}

//
// struct MonitorWidgetLiveActivity_Previews: PreviewProvider {
//    static let attributes = TripAttributes(name: "Pirnaischer Platz", icon: "Tram", stopID: "300001", lineRef: "10000", timetabledTime: "/Date(1681824120000-0000)/", directionRef: "1", publishedLineName: "4", destinationText: "Laubegast", startTime: Date.now)
//    static let contentState = TripAttributes.ContentState(timetabledTime: "/Date(1681824120000-0000)/", estimatedTime: "/Date(1681825120000-0000)/", done: true)
//
//    static var previews: some View {
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal")
//        attributes
//            .previewContext(contentState, viewKind: .content)
//            .preferredColorScheme(.dark)
//            .previewDisplayName("Notification")
//    }
// }
//
// struct MonitorWidgetLiveActivity_Previews: PreviewProvider {
//    static let attributes = TripAttributes(name: "Pirnaischer Platz", icon: "🚊", stopID: "300001", lineRef: "10000", timetabledTime: "/Date(1681824120000-0000)/", directionRef: "1", publishedLineName: "4", destinationText: "Laubegast", startTime: Date.now)
//    
//    
//    static var previews: some View {
//        attributes
//            .previewContext(TripAttributes.ContentState.initial, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact init")
//        attributes
//            .previewContext(TripAttributes.ContentState.in_progress, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact in progress")
//        attributes
//            .previewContext(TripAttributes.ContentState.complete, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact done")
//        // -----
//        attributes
//            .previewContext(TripAttributes.ContentState.initial, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded init")
//        attributes
//            .previewContext(TripAttributes.ContentState.in_progress, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded in progress")
//        attributes
//            .previewContext(TripAttributes.ContentState.complete, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded done")
//        // -----
//        attributes
//            .previewContext(TripAttributes.ContentState.initial, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal init")
//        attributes
//            .previewContext(TripAttributes.ContentState.in_progress, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal in progress")
//        attributes
//            .previewContext(TripAttributes.ContentState.complete, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal done")
//        // -----
//        attributes
//            .previewContext(TripAttributes.ContentState.initial, viewKind: .content)
//            //.preferredColorScheme(.dark)
//            .previewDisplayName("Notification init")
//        attributes
//            .previewContext(TripAttributes.ContentState.in_progress, viewKind: .content)
//            //.preferredColorScheme(.dark)
//            .previewDisplayName("Notification in progress")
//        attributes
//            .previewContext(TripAttributes.ContentState.complete, viewKind: .content)
//            //.preferredColorScheme(.dark)
//            .previewDisplayName("Notification done")
//    }
// }
