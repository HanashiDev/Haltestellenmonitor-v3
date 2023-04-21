//
//  ActivityRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

struct ActivityRequest: Hashable, Codable {
    var token: String
    var stopID: String
    var tripID: String
    var time: String
    var scheduledTime: String
    var realTime: String? = nil
}
