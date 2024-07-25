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
        case "tram":
            return Color.red.opacity(opacity)
        case "bus":
            return Color.blue.opacity(opacity)
        case "trolleybus":
            return Color.blue.opacity(opacity)
        case "urbanRail":
            return Color.green.opacity(opacity)
        case "rail":
            return Color.green.opacity(opacity)
        case "intercityRail":
            return Color.green.opacity(opacity)
        case "cableway":
            return Color.purple.opacity(opacity)
        case "water":
            return Color.purple.opacity(opacity)
        case "taxi":
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
