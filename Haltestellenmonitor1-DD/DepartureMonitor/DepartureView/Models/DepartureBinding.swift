//
//  DepartureBinding.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 13.05.23.
//

import Foundation

class DepartureBinding: ObservableObject {
    @Published var inMinute: Int

    init(inMinute: Int) {
        self.inMinute = inMinute
    }
}
