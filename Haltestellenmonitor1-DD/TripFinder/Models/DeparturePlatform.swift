//
//  DeparturePlatform.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

struct DeparturePlatform: Hashable, Codable {
    var Name: String?
    var type: String

    private enum CodingKeys: String, CodingKey {
        case Name, type = "Type"
    }
}
