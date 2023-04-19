//
//  Mot.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct Mot: Hashable, Codable {
    var type: String
    var Name: String?
    var Direction: String?
    
    private enum CodingKeys : String, CodingKey {
        case type = "Type", Name, Direction
    }
}
