//
//  MonitorWidgetEntryView.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//  Modified by Tom Braune on 03.11.23.
//

import WidgetKit
import SwiftUI
import Intents
import CoreLocation

struct MonitorWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        let prefix = (widgetFamily == .systemLarge || widgetFamily == .systemExtraLarge) ? 16 : 5
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(entry.stop?.getName() ?? "")
                    .font(.headline)
                    .padding(.bottom, 1.0)
                if (entry.filterStopEvents(stopEvents: entry.stopEvents ?? []).isEmpty) {
                    Text("Es wurden keine Abfahrten gefunden.")
                        .font(.subheadline)
                } else {
                    ForEach(entry.filterStopEvents(stopEvents: entry.stopEvents ?? []).prefix(prefix), id: \.self) { stopEvent in
                        MonitorWidgetRow(entry: entry, stopEvent: stopEvent)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding([.top, .leading, .bottom])
        .padding(.trailing, 5.0)
        .widgetBackground(colorScheme == .dark ? Color.black : Color.yellow)
        .widgetURL(URL(string: "widget://stop/\(String(entry.stop?.stopID ?? 0).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
        .dynamicTypeSize(.medium ... .large)
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

/*struct MonitorWidget_Previews: PreviewProvider {
    static var previews: some View {
        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")
        
        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
        
        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large")
        
        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            .previewDisplayName("Extra Large")
    }
}*/
