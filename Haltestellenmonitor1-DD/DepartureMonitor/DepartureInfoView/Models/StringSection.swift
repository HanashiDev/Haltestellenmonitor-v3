//
//  StringModel.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.05.25.
//

struct stringSection: Hashable, Codable {
    var text: String
    let headerLvl: Int8
    let isBold: Bool
    let isItalic: Bool
    let isUnderlined: Bool
    let link: String?
    let isListItem: Bool
}
