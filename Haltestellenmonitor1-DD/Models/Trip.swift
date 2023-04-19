//
//  Trip.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct Trip: Hashable, Codable {
    var Routes: [Route]
}
