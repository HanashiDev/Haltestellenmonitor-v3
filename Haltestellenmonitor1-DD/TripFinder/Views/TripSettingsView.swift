//
//  TripSettingsView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 09.08.25.
//
import SwiftUI

struct TripSettingsView: View {
    @AppStorage("trip_individualTransportType")
    private var individualTransportType: IndividualTransportType = .walking

    @AppStorage("trip_showFare")
    private var showFare: Bool = true

    @AppStorage("trip_showOneBefore")
    private var showOneBefore: Bool = true

    @AppStorage("trip_individualTransportSpeed")
    private var indiviudalTransportSpeed: IndividualTransportSpeed = .normal

    @AppStorage("trip_useWheelchair")
    private var useWheelchair: Bool = false

    @AppStorage("trip_noStairs")
    private var noStairs: Bool = false

    var body: some View {
        Form {

            Toggle("Fahrtkosten anzeigen", isOn: $showFare)

            Toggle("Vorrausgehende Fahrt anzeigen", isOn: $showOneBefore)

            Section(header: Text("Sekundäre Fortbewegung")) {
                Picker("Art", selection: Binding(
                    get: { individualTransportType },
                    set: { individualTransportType = $0 }
                )) {
                    Label("Zu Fuß", systemImage: "figure.walk")
                        .tag(IndividualTransportType.walking)

                    Label("Bike & Ride", systemImage: "figure.walk")
                        .tag(IndividualTransportType.bike_and_ride)

                    Label("Fahrradmitnahme", systemImage: "bicycle")
                        .tag(IndividualTransportType.bike_takealong)

                    Label("Park & Ride", systemImage: "car")
                        .tag(IndividualTransportType.park_and_ride)
                }

                Picker("Geschwindigkeit", selection: Binding(
                    get: { indiviudalTransportSpeed },
                    set: { indiviudalTransportSpeed = $0 }
                )) {
                    Label("Langsam", systemImage: "tortoise")
                        .tag(IndividualTransportSpeed.slow)

                    Label("Normal", systemImage: "figure.walk")
                        .tag(IndividualTransportSpeed.normal)

                    Label("Schnell", systemImage: "hare")
                        .tag(IndividualTransportSpeed.fast)
                }

            }

            Section(header: Text("Mobilitätseinschränkungen")) {
                Toggle("Rollstuhl", isOn: $useWheelchair)
                Toggle("Treppen vermeiden", isOn: $noStairs)
            }
        }
        .navigationTitle("Trip Einstellungen")
    }
}

#Preview("Trip Einstellungen") {
    TripSettingsView()
}
