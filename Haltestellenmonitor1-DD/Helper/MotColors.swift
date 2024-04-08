//
//  MotColors.swift
//  Haltestellenmonitor1-DD
//
//  Created by Kiara on 08.04.24.
//

import SwiftUI

extension String {
    func getColor() -> Color { // TODO: replace purple colors
        let opacity = 0.8
        switch (self) {
        case "Tram":
            return Color.red.opacity(opacity)
        case "CityBus":
            return Color.blue.opacity(opacity)
        case "PlusBus":
            return Color.blue.opacity(opacity)
        case "Bus":
            return Color.blue.opacity(opacity)
        case "IntercityBus":
            return Color.blue.opacity(opacity)
        case "SuburbanRailway":
            return Color.green.opacity(opacity)
        case "RapidTransit":
            return Color.green.opacity(opacity)
        case "Train":
            return Color.green.opacity(opacity)
        case "Cableway":
            return Color.purple.opacity(opacity)
        case "Ferry":
            return Color.purple.opacity(opacity)
        case "HailedSharedTaxi":
            return Color.yellow.opacity(opacity)
        case "Footpath":
            return Color.gray.opacity(opacity)
        case "MobilityStairsUp":
            return Color.purple.opacity(opacity)
        case "MobilityStairsDown":
            return Color.purple.opacity(opacity)
        default:
             return Color.purple.opacity(opacity)
        }
    }
}
