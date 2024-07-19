//
//  FavoriteStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

@MainActor class FavoriteStop: ObservableObject {
    @Published var favorites: [String]
    
    init() {
        if let data = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.data(forKey: "FavoriteStops") {
            if let decoded = try? JSONDecoder().decode([String].self, from: data) {
                favorites = decoded
                return
            }
        }
        
        self.favorites = []
    }
    
    func add(stopPointRef: String) {
        if !isFavorite(stopPointRef: stopPointRef) {
            favorites.append(stopPointRef)
            save()
        }
    }
    
    func remove(stopPointRef: String) {
        if let firstIndex = favorites.firstIndex(of: stopPointRef) {
            favorites.remove(at: firstIndex)
            save()
        }
    }
    
    func isFavorite(stopPointRef: String) -> Bool {
        let cons = favorites.contains { element in
            if element == stopPointRef {
                return true
            } else {
                return false
            }
        }
        return cons
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.set(encoded, forKey: "FavoriteStops")
        }
        // fürs Widget
        
        let sharedUserDefaults = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")
        sharedUserDefaults?.set(favorites, forKey: "WidgetFavs")

    }
}
