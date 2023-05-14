//
//  FavoriteConnection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import Foundation

@MainActor class FavoriteConnection: ObservableObject {
    @Published var favorites: [TripRequestShort]
    
    init() {
        if let data = UserDefaults(suiteName: "group.dev.hanashi.Haltestellenmonitor")?.data(forKey: "FavoriteConnection") {
            if let decoded = try? JSONDecoder().decode([TripRequestShort].self, from: data) {
                favorites = decoded
                return
            }
        }
        
        self.favorites = []
    }
    
    func add(trip: TripRequestShort) {
        favorites.append(trip)
        save()
    }
    
    func remove(trip: TripRequestShort) {
        let firstIndex = favorites.firstIndex { item in
            item.id == trip.id
        }
        if firstIndex != nil {
            favorites.remove(at: firstIndex!)
            save()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults(suiteName: "group.dev.hanashi.Haltestellenmonitor")?.set(encoded, forKey: "FavoriteConnection")
        }
    }
}
