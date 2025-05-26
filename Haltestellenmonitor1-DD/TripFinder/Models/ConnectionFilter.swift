//
//  ConnectionFilter.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

class ConnectionFilter: ObservableObject {
    @Published var startStop: ConnectionStop?
    @Published var endStop: ConnectionStop?
    @Published var start = false
}
