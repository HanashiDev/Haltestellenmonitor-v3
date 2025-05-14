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

// accessabiity Lables

func getAccessibilityLabel(motType: MOTType) -> String {
    switch motType {
    case .Tram:
        return "Straßenbahn"
    case .Bus:
        return "Bus"
    case .Train:
        return "Zug"
    case .CableCar:
        return "Standseilbahn/Schwebebahn"
    case .Boat:
        return "Fähre"
    case .Default:
        return ""
    case .Up:
        return "Treppe aufwärts"
    case .Down:
        return "Treppe abwärts"
    case .Walking:
        return "Zu Fuß"
    }
}

func getAccessibilityLabelEFA(iconId: Int) -> String {
    switch iconId {
    case 4:
        return getAccessibilityLabel(motType: .Tram)
    case 3:
        return getAccessibilityLabel(motType: .Bus)
    case 2, 6:
        return getAccessibilityLabel(motType: .Train)
    case 9:
        return getAccessibilityLabel(motType: .CableCar)
    case 10:
        return getAccessibilityLabel(motType: .Boat)
    default:
        return getAccessibilityLabel(motType: .Default)
    }
}

func getAccessibilityLabelVVO(motType: String) -> String {
    switch motType {
    case "Tram":
        return getAccessibilityLabel(motType: .Tram)
    case "CityBus", "PlusBus", "Bus", "IntercityBus":
        return getAccessibilityLabel(motType: .Bus)
    case "Train", "RapidTransit", "SuburbanRailway":
        return getAccessibilityLabel(motType: .Train)
    case "Cableway":
        return getAccessibilityLabel(motType: .CableCar)
    case "Ferry":
        return getAccessibilityLabel(motType: .Boat)
    case "Footpath":
        return getAccessibilityLabel(motType: .Walking)
    case "MobilityStairsUp":
        return getAccessibilityLabel(motType: .Up)
    case "MobilityStairsDown":
        return getAccessibilityLabel(motType: .Down)
    default:
        return getAccessibilityLabel(motType: .Default)
    }
}

// icons

func getIconStandard(motType: MOTType) -> String {
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
        return "🚶"
    }
}

func getIconEFA(iconId: Int) -> String {
    switch iconId {
    case 4:
        return getIconStandard(motType: .Tram)
    case 3:
        return getIconStandard(motType: .Bus)
    case 2, 6:
        return getIconStandard(motType: .Train)
    case 9:
        return getIconStandard(motType: .CableCar)
    case 10:
        return getIconStandard(motType: .Boat)
    default:
        return getIconStandard(motType: .Default)
    }
}

func getIconVVO(motType: String) -> String {
    switch motType {
    case "Tram":
        return  getIconStandard(motType: .Tram)
    case "CityBus", "PlusBus", "Bus", "IntercityBus":
        return getIconStandard(motType: .Bus)
    case "Train", "RapidTransit", "SuburbanRailway":
        return getIconStandard(motType: .Train)
    case "Cableway":
        return getIconStandard(motType: .CableCar)
    case "Ferry":
        return getIconStandard(motType: .Boat)
    case "Footpath":
        return getIconStandard(motType: .Walking)
    case "MobilityStairsUp":
        return getIconStandard(motType: .Up)
    case "MobilityStairsDown":
        return getIconStandard(motType: .Down)
    default:
        return getIconStandard(motType: .Default)
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
