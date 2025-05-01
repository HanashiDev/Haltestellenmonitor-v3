//
//  ContentView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI
import BackgroundTasks

struct ContentView: View {
    @State var selection = 1
    @State var oldSelection = 1
    @State var showingSheet = false
    @State var openingStop = stops[0]
    // @State var openingDeparture = departureM.Departures[0]
    @StateObject var locationManager = LocationManager()
    @StateObject var favoriteStops = FavoriteStop()
    @StateObject var pushTokenHistory = PushTokenHistory()
    @StateObject var stopManager = StopManager()

    var body: some View {
        TabView(selection: $selection.onUpdate {
            if selection == oldSelection {
                switch selection {
                case 1:
                    stopManager.selectedStop = nil
                    case 2:
                    stopManager.presentedStops.removeAll()
                    case 3:
                    stopManager.presentedMapStops.removeAll()
                default:
                    break
                }
            }
            oldSelection = selection
        }) {
            StopsView().tabItem {
                Label("Abfahrten", systemImage: "h.circle")
            }.tag(1)
            ConnectionView().tabItem {
                Label("Verbindungen", systemImage: "app.connected.to.app.below.fill")
            }.tag(2)
            MapView().tabItem {
                Label("Karte", systemImage: "map")
            }.tag(3)
            About().tabItem {
                Label("Über", systemImage: "info.circle.fill")
            }.tag(4)
        }
        /*.sheet(isPresented: $showingSheet, content: {
            NavigationStack {
                SingleTripView(stop: openingStop, departure: openingDeparture)
            }
        })*/
        .environmentObject(locationManager)
        .environmentObject(favoriteStops)
        .environmentObject(pushTokenHistory)
        .environmentObject(stopManager)
        .onOpenURL { url in
            goToStop(url: url)
        }
    }

    func goToStop(url: URL) {
        if url.host() == "stop" {
            selection = 1
        } else if url.host() == "trip" {
            if url.pathComponents.count != 6 {
                return
            }
            selection = 1

//            openingStop = Stop(stopId: Int(url.pathComponents[1]) ?? 0, name: "", city: "", gpsX: "0", gpsY: "0")
//            openingDeparture = Departure(Id: url.pathComponents[2], LineName: url.pathComponents[3], Direction: url.pathComponents[4], Mot: "", ScheduledTime: url.pathComponents[5])
//
//            showingSheet = true
        }
    }
}

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
