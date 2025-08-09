//
//  TripSettingsView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 09.08.25.
//
import SwiftUI

struct TripSettingsView: View {
    @AppStorage("interchangeMethod")
    private var interchangeMethod: IndividualTransportType = .walking

    var body: some View {
        Form {
            Picker("Art der sekundären Fortbewegung", selection: Binding(
                get: { interchangeMethod },
                set: { interchangeMethod = $0 }
            )) {
                Label("Zu Fuß", systemImage: "figure.walk")
                    .tag(IndividualTransportType.walking)

                Label("Bike & Ride", systemImage: "figure.walk")
                    .tag(IndividualTransportType.bike_and_ride)

                Label("Fahrradmitnahme", systemImage: "bicycle")
                    .tag(IndividualTransportType.bike_takealong)
            }
            .pickerStyle(.inline)
        }
        .navigationTitle("Trip Einstellungen")
    }
}

#Preview("Trip Einstellungen") {
    TripSettingsView()
}
