//
//  DepartureDisclosureSection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct DepartureDisclosureSection: View {
    @EnvironmentObject var departureFilter: DepartureFilter

    var body: some View {
        Toggle(isOn: $departureFilter.tram) {
            HStack {
                Text(getIcon(motType: .Tram))
                Text("Straßenbahn")
            }
        }
        Toggle(isOn: $departureFilter.bus) {
            HStack {
                Text(getIcon(motType: .Bus))
                Text("Bus")
            }
        }
        Toggle(isOn: $departureFilter.suburbanRailway) {
            HStack {
                Text(getIcon(motType: .Train))
                Text("S-Bahn")
            }
        }
        Toggle(isOn: $departureFilter.train) {
            HStack {
                Text(getIcon(motType: .Train))
                Text("Zug")
            }
        }
        Toggle(isOn: $departureFilter.cableway) {
            HStack {
                Text(getIcon(motType: .CableCar))
                Text("Standseilbahn")
            }
        }
        Toggle(isOn: $departureFilter.ferry) {
            HStack {
                Text(getIcon(motType: .Boat))
                Text("Fähre")
            }
        }
    }
}

struct DepartureDisclosureSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DepartureDisclosureSection()

        }.environmentObject(DepartureFilter())
    }
}
