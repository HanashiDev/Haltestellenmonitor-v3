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
                Text(entry.departureMonitor?.Name ?? "")
                    .font(.headline)
                    .padding(.bottom, 1.0)
                if (entry.filterDepartures(departures:  entry.departureMonitor?.Departures ?? []).isEmpty) {
                    Text("Es wurden keine Abfahrten gefunden.")
                        .font(.subheadline)
                } else {
                    ForEach(entry.filterDepartures(departures:  entry.departureMonitor?.Departures ?? []).prefix(prefix), id: \.self) { departure in
                        MonitorWidgetRow(entry: entry, departure: departure)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding([.top, .leading, .bottom])
        .padding(.trailing, 5.0)
        .background(colorScheme == .dark ? Color.black : Color.yellow)
        .widgetURL(URL(string: "widget://stop/\(entry.getStopID(Name: entry.departureMonitor?.Name ?? "-").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
        .dynamicTypeSize(.medium ... .large)
    }
}

struct MonitorWidget_Previews: PreviewProvider {
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
}
