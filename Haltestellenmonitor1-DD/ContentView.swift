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
    @StateObject var locationManager = LocationManager()
    @StateObject var favoriteStops = FavoriteStop()
    @StateObject var pushTokenHistory = PushTokenHistory()
    @StateObject var stopManager = StopManager()

    var body: some View {
        TabView(selection: $selection.onUpdate {
            if selection == oldSelection {
                if selection == 1 {
                    stopManager.selectedStop = nil
                } else if (selection == 2) {
                    stopManager.presentedStops.removeAll()
                }
            }
            oldSelection = selection
        }) {
            StopsView().tabItem {
                Label("Abfahrten", systemImage: "h.circle") }.tag(1)
            ConnectionView().tabItem { Label("Verbindungen", systemImage: "app.connected.to.app.below.fill") }.tag(2)
            Text("Tab Content 3").tabItem { Label("Karte", systemImage: "map") }.tag(3)
        }
        .environmentObject(locationManager)
        .environmentObject(favoriteStops)
        .environmentObject(pushTokenHistory)
        .environmentObject(stopManager)
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
