//
//  DapertureFilter.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

class DepartureFilter: ObservableObject {
    @Published var tram = true
    @Published var bus = true
    @Published var suburbanRailway = true
    @Published var train = true
    @Published var cableway = true
    @Published var ferry = true
}
