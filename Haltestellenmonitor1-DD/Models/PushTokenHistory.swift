//
//  PushTokenHistory.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

@MainActor class PushTokenHistory: ObservableObject {
    @Published var tokens: [String]
    
    init() {
        if let data = UserDefaults(suiteName: "group.dev.hanashi.Haltestellenmonitor")?.data(forKey: "PushTokenHistory") {
            if let decoded = try? JSONDecoder().decode([String].self, from: data) {
                tokens = decoded
                return
            }
        }
        
        self.tokens = []
    }
    
    func add(token: String) {
        if !isInHistory(token: token) {
            tokens.append(token)
            save()
        }
    }
    
    func isInHistory(token: String) -> Bool {
        let cons = tokens.contains { element in
            if element == token {
                return true
            } else {
                return false
            }
        }
        return cons
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(tokens) {
            UserDefaults(suiteName: "group.dev.hanashi.Haltestellenmonitor")?.set(encoded, forKey: "PushTokenHistory")
        }
    }
}
