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
                Text("🚊")
                Text("Straßenbahn")
            }
        }
        Toggle(isOn: $departureFilter.bus) {
            HStack {
                Text("🚍")
                Text("Bus")
            }
        }
        Toggle(isOn: $departureFilter.suburbanRailway) {
            HStack {
                Text("🚈")
                Text("S-Bahn")
            }
        }
        Toggle(isOn: $departureFilter.train) {
            HStack {
                Text("🚆")
                Text("Zug")
            }
        }
        Toggle(isOn: $departureFilter.cableway) {
            HStack {
                Text("🚞")
                Text("Standseilbahn")
            }
        }
        Toggle(isOn: $departureFilter.ferry) {
            HStack {
                Text("⛴️")
                Text("Fähre")
            }
        }
        Toggle(isOn: $departureFilter.taxi) {
            HStack {
                Text("🚖")
                Text("Taxi")
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
