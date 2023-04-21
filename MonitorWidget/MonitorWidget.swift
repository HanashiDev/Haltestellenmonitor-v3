//
//  MonitorWidget.swift
//  MonitorWidget
//
//  Created by Peter Lohse on 19.04.23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    typealias Entry = MonitorEntry

    func placeholder(in context: Context) -> MonitorEntry {
        MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MonitorEntry) -> ()) {
        let entry = MonitorEntry(date: Date(), configuration: configuration, departureMonitor: departureM)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let stopID = configuration.stopType?.identifier ?? "33000028"
        
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest(stopid: stopID))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var entries: [MonitorEntry] = []
            var departureMonitor: DepartureMonitor? = nil
            guard error == nil else {
                print ("error: \(error!)")
                let currentDate = Date()
                for i in 0 ..< 72 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: 30 * i, to: currentDate)!
                    let entry = MonitorEntry(date: entryDate, configuration: configuration, departureMonitor: departureMonitor)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                return
            }

            guard let content = data else {
                print("No data")
                let currentDate = Date()
                for i in 0 ..< 72 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: 30 * i, to: currentDate)!
                    let entry = MonitorEntry(date: entryDate, configuration: configuration, departureMonitor: departureMonitor)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                return
            }


            DispatchQueue.main.async {
                print("\(Date())")
                
                do {
                    let decoder = JSONDecoder()
                    departureMonitor = try decoder.decode(DepartureMonitor.self, from: content)
                } catch {
                    print(error)
                }
                
                let currentDate = Date()
                for i in 0 ..< 72 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: 30 * i, to: currentDate)!
                    let entry = MonitorEntry(date: entryDate, configuration: configuration, departureMonitor: departureMonitor)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }

        }
        task.resume()
    }
}

struct MonitorWidget: Widget {
    let kind: String = "MonitorWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MonitorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Haltestellenmonitor")
        .description("Widget zur Anzeige der Abfahrten an einer Haltestelle.")
    }
}
