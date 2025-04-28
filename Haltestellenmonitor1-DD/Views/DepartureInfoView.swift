//
//  DepartureInfoView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.03.25.
//

import Foundation
import SwiftUI

private extension NSAttributedString {
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

struct stringSection: Hashable, Codable {
    var text: String
    let headerLvl: Int8
    let isBold: Bool
    let isItalic: Bool
    let isUnderlined: Bool
    let link: String?
    let isListItem: Bool
}

    


struct DepartureInfoViewRow: View {
    let infoLink: InfoLink
    @State private var convertedText: [[stringSection]] = []
    @State private var subtitleText: String = ""
    @State private var convertedTexts: [Text] = []
    
    func checkBold(_ attributes: [NSAttributedString.Key : Any]) -> Bool {
        if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitBold) {
            return true
        }
        return false
    }
    func checkItalic(_ attributes: [NSAttributedString.Key : Any]) -> Bool {
        if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            return true
        }
        return false
    }
    func getLink(_ attributes: [NSAttributedString.Key : Any]) -> String? {
        if let url = attributes[.link] as? URL {
            return url.absoluteString
        } else if let urlString = attributes[.link] as? String {
            return urlString
        }
        return nil
    }

    func getHeaderLevel(_ attributes: [NSAttributedString.Key : Any]) -> Int8 {
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
            if let level = paragraphStyle.value(forKey: "headerLevel") as? Int8 {
                return level
            }
        }
        return 0
    }
    func checkUnderlined(_ attributes: [NSAttributedString.Key : Any]) -> Bool {
        if let _ = attributes[.underlineStyle] {
            return true
        }
        return false
    }
    func checkList(_ attributes: [NSAttributedString.Key : Any]) -> Bool {
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
            .characterEncoding: String.Encoding.utf8.rawValue,
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
            .characterEncoding: String.Encoding.utf8.rawValue,
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


    var body: some View {
        DisclosureGroup(
            content: {
                VStack {
                    ForEach(convertedText, id: \.self) {section in
                        
                        // Add Space before headers & sections
                        if let item = section.first {
                            if item.headerLvl > 0 && convertedText.firstIndex(of: section) ?? 0 > 0 {
                                Spacer()
                                    .frame(height: 4 * (7 - CGFloat(item.headerLvl)))
                            } else {
                                Spacer()
                                    .frame(height: 8)
                            }
                        }
                        
                        if section.first?.isListItem ?? false {
                            HStack(alignment: .top, spacing: 8) {
                                Text("-")
                                    .frame(width: 10, alignment: .trailing)
                                    .fixedSize()
                                
                                formattedText(from: section)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 0)
                        } else {
                            HStack {
                                formattedText(from: section)
                                Spacer()
                            }
                        }
                    }
                }
            },
            label: {
                VStack (alignment: .leading){
                    
                    Text(subtitleText)
                    
                    if infoLink.title != nil && !infoLink.title!.isEmpty {
                        Text((infoLink.title!)
                            .replacingOccurrences(of: "oe", with: "ö")
                            .replacingOccurrences(of: "ue", with: "ü")
                            .replacingOccurrences(of: "ae", with: "ä"))
                        .foregroundColor(.secondary)
                    }
                }
            }
        )
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    subtitleText = getTitle(infoLink.subtitle)
                    convertedText = convertHTML(infoLink.content)
                }
            }
        }
    }

}

struct DepartureInfoView: View {
    let stopEvent: StopEvent

    var body: some View {
        // only use after check for stopEvent.infos exists
        Group {
            VStack {
                List(stopEvent.infos!, id: \.self) { info in
                    ForEach(info.infoLinks, id: \.self) { link in
                        DepartureInfoViewRow(infoLink: link)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Meldungen für \(stopEvent.getName())")
    }
}

//struct DepartureInfoPreview: PreviewProvider {
//    static var previews: some View {
//        //        NavigationStack {
//        DepartureInfoView(
//            stopEvent: StopEvent(
//                location: Location(
//                    Id: "de:14612:28",
//                    IsGlobalId: true,
//                    Name: "HBF DD",
//                    DisassembledName: "",
//                    type: "stop",
//                    Coord: [],
//                    Properties: Stop_Property(stopId: "de:14612:28")
//                ),
//                departureTimePlanned: "2025-03-26T06:00:00Z",
//                departureTimeBaseTimetable: "2025-03-26T06:00:00Z",
//                transportation: Transportation(
//                    id: "ddb:98X27: :R:j25",
//                    name: "ICE 870 InterCityExpress",
//                    number: "870",
//                    product: Product(id: 0, class: 0, name: "Zug", iconId: 6),
//                    properties: T_Properties(),
//                    destination: Place(id: "", name: "", type: "")
//                ),
//                infos: [
//                    Info(
//                        priority: "Medium",
//                        id: "",
//                        version: 1,
//                        type: "Linienänderung",
//                        infoLinks: [
//                            InfoLink(
//                                urlText: "",
//                                url: "",
//                                content: "Hallo Welt",
//                                subtitle: "hi"
//                            )
//                        ]
//                    ),
//                    Info(
//                        priority: "Medium",
//                        id: "",
//                        version: 1,
//                        type: "Linienänderung2",
//                        infoLinks: [
//                            InfoLink(
//                                urlText: "",
//                                url: "",
//                                content:
//                                    "Hallo Welt wie geht es dir heute mir geht es gut und dir auch? das hier ist jetzt ganz viel Text um die expansion weiter zu testen, wenn der Text länger ist soll nämlich die View weiter nach unten expandiert werden",
//                                subtitle: "hi",
//                                title: "Test"
//                            ),
//                            InfoLink(
//                                urlText: "",
//                                url: "",
//                                content:
//                                    "<h1>Hallö Welt</h1><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>",
//                                subtitle: "hi",
//                                title: "Test2"
//                            ),
//                        ]
//                    ),
//                ]
//            )
//        )
//
//    }
//    //    }
//}
