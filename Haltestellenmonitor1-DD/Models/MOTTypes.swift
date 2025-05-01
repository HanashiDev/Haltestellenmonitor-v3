//
//  MOTTypes.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 20.04.25.
//

import SwiftUI

enum MOTType {
    case Tram, Bus, Train, CableCar, Boat, Default, Walking, Up, Down
}

func getIcon(motType: MOTType) -> String {
    switch motType {
    case .Tram:
        return "🚊"
    case .Bus:
        return "🚍"
    case .Train:
        return "🚆"
    case .CableCar:
        return "🚞"
    case .Boat:
        return "⛴️"
    case .Default:
        return "🚊"
    case .Up:
        return "📈"
    case .Down:
        return "📉"
    case .Walking:
        return "🚶‍♂️"
    }
}

func getIconEFA(iconId: Int) -> String {
    switch iconId {
    case 4:
        return getIcon(motType: .Tram)
    case 3:
        return getIcon(motType: .Bus)
    case 2, 6:
        return getIcon(motType: .Train)
    case 9:
        return getIcon(motType: .CableCar)
    case 10:
        return getIcon(motType: .Boat)
    default:
        return getIcon(motType: .Default)
    }
}

func getIconVVO(motType: String) -> String {
    switch motType {
    case "Tram":
        return  getIcon(motType: .Tram)
    case "CityBus", "PlusBus", "Bus", "IntercityBus":
        return getIcon(motType: .Bus)
    case "Train", "RapidTransit", "SuburbanRailway":
        return getIcon(motType: .Train)
    case "Cableway":
        return getIcon(motType: .CableCar)
    case "Ferry":
        return getIcon(motType: .Boat)
    case "Footpath":
        return getIcon(motType: .Walking)
    case "MobilityStairsUp":
        return getIcon(motType: .Up)
    case "MobilityStairsDown":
        return getIcon(motType: .Down)
    default:
        return getIcon(motType: .Default)
    }
}

// Colors

func getColor(motType: MOTType) -> Color {
    let opacity = 0.8
    switch motType {
    case .Tram:
        return Color.red.opacity(opacity)
    case .Bus:
        return Color.blue.opacity(opacity)
    case .Train:
        return Color.green.opacity(opacity)
    case .CableCar:
        return Color.gray.opacity(opacity)
    case .Boat:
        return Color.cyan.opacity(opacity)
    case .Walking, .Up, .Down:
        return Color.mint.opacity(opacity)
    case .Default:
        return Color.purple.opacity(opacity)
    }
}

func getColorEFA(iconId: Int) -> Color {
    switch iconId {
    case 4:
        return getColor(motType: .Tram)
    case 3:
        return getColor(motType: .Bus)
    case 2, 6:
        return getColor(motType: .Train)
    case 9:
        return getColor(motType: .CableCar)
    case 10:
        return getColor(motType: .Boat)
    default:
        return getColor(motType: .Default)
    }
}

func getColorVVO(motType: String) -> Color {
    switch motType {
    case "Tram":
        return  getColor(motType: .Tram)
    case "CityBus", "PlusBus", "Bus", "IntercityBus":
        return getColor(motType: .Bus)
    case "Train", "RapidTransit", "SuburbanRailway":
        return getColor(motType: .Train)
    case "Cableway":
        return getColor(motType: .CableCar)
    case "Ferry":
        return getColor(motType: .Boat)
    case "Footpath":
        return getColor(motType: .Walking)
    case "MobilityStairsUp":
        return getColor(motType: .Up)
    case "MobilityStairsDown":
        return getColor(motType: .Down)
    default:
        return getColor(motType: .Default)
    }
}
