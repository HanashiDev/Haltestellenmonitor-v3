//
//  ShowManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

class StopManager: ObservableObject {
    @Published var selectedStop: Stop?
    @Published var presentedStops = [Stop]()
}
