//
//  ActivityRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

struct ActivityRequest: Hashable, Codable {
    var token: String
    var stopGID: String
    var lineRef: String
    var directionRef: String
    var timetabledTime: String
    var estimatedTime: String
}
