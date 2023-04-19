//
//  MonitorWidgetRow.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI
import WidgetKit

struct MonitorWidgetRow: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var departure: Departure
    
    var body: some View {
        HStack {
            Text(departure.getName())
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            if (entry.configuration.displayFormat == DisplayFormat.time) {
                Text(widgetFamily == .systemSmall ? "\(departure.getRealTime())" : "\(departure.getRealTime()) Uhr")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            } else {
                Text(widgetFamily == .systemSmall ? "\(departure.getIn(date: entry.date))" : "in \(departure.getIn(date: entry.date)) min")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            }
        }
    }
}

struct MonitorWidgetRow_Previews: PreviewProvider {
    static var previews: some View {
        MonitorWidgetRow(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM), departure: departureM.Departures[0])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")
        
        MonitorWidgetRow(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM), departure: departureM.Departures[0])
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
        
        MonitorWidgetRow(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM), departure: departureM.Departures[0])
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large")
        
        MonitorWidgetRow(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM), departure: departureM.Departures[0])
            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            .previewDisplayName("Extra Large")
    }
}
