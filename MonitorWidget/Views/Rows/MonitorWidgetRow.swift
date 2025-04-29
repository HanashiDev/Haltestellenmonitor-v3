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
    var stopEvent: StopEvent
    
    var body: some View {
        HStack {
            Text(getNumber())
                .font(.subheadline)
                .lineLimit(1)
                .padding(.horizontal, 3)
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(stopEvent.getColor())
                }
            Text(stopEvent.transportation.destination.name)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            if (entry.configuration.displayFormat == DisplayFormat.time) {
                Text(widgetFamily == .systemSmall ? "\(stopEvent.getEstimatedTime())" : "\(stopEvent.getEstimatedTime()) Uhr")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            } else {
                Text(widgetFamily == .systemSmall ? "\(stopEvent.getIn(date: entry.date))" : "in \(stopEvent.getIn(date: entry.date)) min")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            }
        }
    }
    
    // Get Correct Number for Trains like ICE, IC, EC
    func getNumber() -> String {
        if self.stopEvent.transportation.properties.specialFares != nil {
            return "\(self.stopEvent.transportation.properties.trainType ?? "")\(self.stopEvent.transportation.properties.trainNumber ?? "")"
        }
        return "\(self.stopEvent.transportation.number)"
    }
}

/*struct MonitorWidgetRow_Previews: PreviewProvider {
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
}*/
