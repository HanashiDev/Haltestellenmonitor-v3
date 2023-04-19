//
//  ContentView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var favoriteStops = FavoriteStop()

    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            StopsView().tabItem {
                Label("Haltestellen", systemImage: "h.circle") }.tag(1)
            Text("Tab Content 2").tabItem { Label("Verbindungen", systemImage: "app.connected.to.app.below.fill") }.tag(2)
            Text("Tab Content 3").tabItem { Label("Karte", systemImage: "map") }.tag(3)
        }
        .environmentObject(locationManager)
        .environmentObject(favoriteStops)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
