//
//  MonitorWidget.swift
//  MonitorWidget
//
//  Created by Peter Lohse on 19.04.23.
//  Modiefied by Tom Braune on 03.11.23.
//  Credit to https://github.com/AKORA-Studios for helping with the LocationManager
//

import WidgetKit
import SwiftUI
import Intents
import CoreLocation
import MapKit

class Provider: IntentTimelineProvider {

    typealias Entry = MonitorEntry

    let widgetLocationManager = WidgetLocationManager()

    func placeholder(in context: Context) -> MonitorEntry {
        MonitorEntry(date: Date(), configuration: ConfigurationIntent(), stop: nil, stopEvents: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MonitorEntry) -> Void) {
        // TODO: stopEvents
        let entry = MonitorEntry(date: Date(), configuration: configuration, stop: stops[0], stopEvents: [])
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {

        var stop: Stop = Stop.getByGID(gid: "de:14612:28")!
        var favoriteStops: [Int] = []

        if configuration.favoriteFilter == FavoriteFilter.true {
            if let data = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.data(forKey: "FavoriteStops") {
                if let decoded = try? JSONDecoder().decode([Int].self, from: data) {
                    favoriteStops = decoded
                }
            }

            // Retrieving stop data for marked favorites
            var favStops: [Stop] = stops.filter {favorite in
                return favoriteStops.contains(favorite.stopID)
            }

            if favStops.isEmpty {
                print("Widget: No favorites found.")

            } else {
                var favStopsLoc: [Stop] = []
                // Retrieving location data
                Task {
                    await widgetLocationManager.fetchLocation { llocation in
                        print("Widget: >>>", llocation.coordinate)}
                }
                // Dresden town hall GPS coordinates as default
                let location = widgetLocationManager.llocation ?? CLLocation(latitude: +51.04750, longitude: +13.74035)

                // sorting by distance
                favStops.forEach {stop in
                    var newStop = stop
                    newStop.distance = location.distance(from: CLLocation(latitude: stop.coordinates.latitude, longitude: stop.coordinates.longitude))
                    favStopsLoc.append(newStop)
                }
                favStops = favStopsLoc.sorted {$0.getDistance() < $1.getDistance()}

                stop = favStops[0]
            }
        } else {
            let stopTmp = Stop.getBystopID(stopID: configuration.stopType?.identifier ?? "0")
            if stopTmp != nil {
                stop = stopTmp!
            }
        }
        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_DM_REQUEST")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"

        request.httpBody = createDepartureRequest(stopId: stop.gid, itdDate: getDateStampURL(), itdTime: getTimeStampURL()).data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            var entries: [MonitorEntry] = []
            var stopEvents: [StopEvent] = []
            guard error == nil else {
                print("Widget error: \(error!)")
                self.getTimeline(for: configuration, in: context, completion: completion)
                return
            }

            guard let content = data else {
                print("Widget: No data")
                self.getTimeline(for: configuration, in: context, completion: completion)
                return
            }

            DispatchQueue.main.async {
                do {
                    let stopEventContainer = try JSONDecoder().decode(StopEventContainer.self, from: content)
                    stopEvents = stopEventContainer.stopEvents ?? []

                } catch {
                    print("Widget: JSON decoding failed")
                    self.getTimeline(for: configuration, in: context, completion: completion)
                    return
                }

                let currentDate = Date()
                for i in 0 ..< 72 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: 30 * i, to: currentDate)!
                    let entry = MonitorEntry(date: entryDate, configuration: configuration, stop: stop, stopEvents: stopEvents)
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
        .contentMarginsDisabledIfAvailable()
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
