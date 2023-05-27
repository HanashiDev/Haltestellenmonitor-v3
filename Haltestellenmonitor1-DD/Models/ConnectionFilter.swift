//
//  ConnectionFilter.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

class ConnectionFilter: ObservableObject {
    @Published var startStop: ConnectionStop? = nil
    @Published var endStop: ConnectionStop? = nil
    @Published var start = false
}
