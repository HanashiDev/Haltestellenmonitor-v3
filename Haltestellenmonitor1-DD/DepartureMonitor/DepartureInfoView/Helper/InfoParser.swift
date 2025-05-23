//
//  InfoParser.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.05.25.
//

import Foundation
import SwiftUI

extension NSAttributedString {
    func split(separator: String) -> [NSAttributedString] {
        var result = [NSAttributedString]()
        let separatedStrings = string.components(separatedBy: separator)
        var range = NSRange(location: 0, length: 0)
        for string in separatedStrings {
            range.length = string.utf16.count
            let attributedString = attributedSubstring(from: range)
            result.append(attributedString)
            range.location += range.length + separator.utf16.count
        }
        return result
    }
}

func checkBold(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
    if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitBold) {
        return true
    }
    return false
}

func checkItalic(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
    if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
        return true
    }
    return false
}

func getLink(_ attributes: [NSAttributedString.Key: Any]) -> String? {
    if let url = attributes[.link] as? URL {
        return url.absoluteString
    } else if let urlString = attributes[.link] as? String {
        return urlString
    }
    return nil
}

func getHeaderLevel(_ attributes: [NSAttributedString.Key: Any]) -> Int8 {
    if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
        if let level = paragraphStyle.value(forKey: "headerLevel") as? Int8 {
            return level
        }
    }
    return 0
}

func checkUnderlined(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
    if let _ = attributes[.underlineStyle] {
        return true
    }
    return false
}

func checkList(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
    if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
        if let textLists = paragraphStyle.value(forKey: "textLists") as? NSArray {
            if textLists.count > 0 {
                return true
            }
        }
    }
    return false
}

func getTitle(_ html: String) -> String {
    guard let data = html.data(using: .utf8) else { return "" }

    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]

    if let attributedString = try? NSAttributedString(
        data: data,
        options: options,
        documentAttributes: nil
    ) {
        return attributedString.string
    }
    return ""
}

func convertHTML(_ html: String) -> [[stringSection]] {
    guard let data = html.data(using: .utf8) else { return [] }

    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]

    if let attributedString = try? NSAttributedString(
        data: data,
        options: options,
        documentAttributes: nil
    ) {
        var all_strings: [[stringSection]] = []
        for section in (attributedString.split(separator: "\n")) {
            var section_strings: [stringSection] = []
            section.enumerateAttributes(in: NSRange(location: 0, length: section.length)) { attributes, range, _ in
                let header = getHeaderLevel(attributes)
                if header > 0 {
                    all_strings.append([stringSection(text: section.attributedSubstring(from: range).string, headerLvl: header, isBold: checkBold(attributes), isItalic: checkItalic(attributes), isUnderlined: checkUnderlined(attributes), link: nil, isListItem: checkList(attributes))])
                } else {
                    section_strings.append(stringSection(text: section.attributedSubstring(from: range).string, headerLvl: 0, isBold: checkBold(attributes), isItalic: checkItalic(attributes), isUnderlined: checkUnderlined(attributes), link: getLink(attributes), isListItem: checkList(attributes)))
                }
            }
            if section_strings.count > 0 {
                all_strings.append(section_strings)
            }
        }
        return all_strings
    } else {
        return []
    }
}

func formattedText(from sections: [stringSection]) -> Text {
    return sections.enumerated().reduce(Text("")) { partialResult, item in
        var (_, section) = item

        // pre iOS 18.0 fix
        if section.isListItem && section.text.contains("•") {
            section.text = ""
        }

        var sectionText: Text

        // Apply link if present
        if let link = section.link {
            let text = "[\(section.text)](\(link))"
            sectionText = Text(.init(text))
        } else {
            sectionText = Text(section.text)
        }

        // Apply formatting based on properties
        if section.isBold {
            sectionText = sectionText.bold()
        }

        if section.isItalic {
            sectionText = sectionText.italic()
        }

        if section.isUnderlined {
            sectionText = sectionText.underline()
        }

        // Apply font size based on header level
        switch section.headerLvl {
        case 1:
            sectionText = sectionText.font(.largeTitle)
        case 2:
            sectionText = sectionText.font(.title)
        case 3:
            sectionText = sectionText.font(.title2)
        case 4:
            sectionText = sectionText.font(.title3)
        default: // 0
            sectionText = sectionText.font(.body)
        }

        return partialResult + sectionText
    }
}
