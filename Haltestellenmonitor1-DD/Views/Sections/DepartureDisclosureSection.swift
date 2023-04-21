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
                Image(systemName: "cablecar")
                Text("Straßenbahn")
            }
        }
        Toggle(isOn: $departureFilter.bus) {
            HStack {
                Image(systemName: "bus")
                Text("Bus")
            }
        }
        Toggle(isOn: $departureFilter.suburbanRailway) {
            HStack {
                Image(systemName: "tram")
                Text("S-Bahn")
            }
        }
        Toggle(isOn: $departureFilter.train) {
            HStack {
                Image(systemName: "tram")
                Text("Zug")
            }
        }
        Toggle(isOn: $departureFilter.cableway) {
            HStack {
                Image(systemName: "cablecar.fill")
                Text("Standseilbahn")
            }
        }
        Toggle(isOn: $departureFilter.ferry) {
            HStack {
                Image(systemName: "ferry")
                Text("Fähre")
            }
        }
        Toggle(isOn: $departureFilter.taxi) {
            HStack {
                Image(systemName: "car")
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
