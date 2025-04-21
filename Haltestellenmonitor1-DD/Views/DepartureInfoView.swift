//
//  DepartureInfoView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.03.25.
//

import Foundation
import SwiftUI

struct DepartureInfoViewRow: View {
    let infoLink: InfoLink
    @State private var convertedText: NSAttributedString = NSAttributedString(string: "")
    @State private var subtitleText: NSAttributedString = NSAttributedString(string: "")


    func convertHTML(_ html: String) -> NSAttributedString? {
        
        // insert missing list markers
        let marker_pattern = "<li>(.*?)<\\/li>"
        let marker_regex = try! NSRegularExpression(pattern: marker_pattern, options: [])
        
        let range = NSRange(location: 0, length: html.utf16.count)
        let modifiedHTML = marker_regex.stringByReplacingMatches(in: html, options: [], range: range, withTemplate: "<li>• $1</li>")
        
        // insert space before headings, but not before the first
        let spacing_pattern = "(<h\\d>)"
        let spacing_regex = try! NSRegularExpression(pattern: spacing_pattern, options: [])
        
        let matches = spacing_regex.matches(in: modifiedHTML, range: NSRange(location: 0, length: modifiedHTML.utf16.count))
        
        var temp_html = modifiedHTML as NSString
        for match in matches.dropFirst().reversed() {
            let contentRange = match.range(at: 1)
            let content = temp_html.substring(with: contentRange)
            let replacement = "<br>\(content)"
            temp_html = temp_html.replacingCharacters(in: match.range, with: replacement) as NSString
        }
        
        let finalHTML = temp_html as String
        

        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 17px;
              }
              a {
                color: #F4C643;
              }
            </style>
          </head>
          <body>
            \(finalHTML)
          </body>
        </html>
        """
        
        guard let data = htmlTemplate.data(using: .utf8) else { return nil }
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 32
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
            .defaultAttributes: [
                NSAttributedString.Key.paragraphStyle: paraStyle
            ]
        ]

        if let attributedString = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) {
            return attributedString
        } else {
            return nil
        }
    }

    var body: some View {
        DisclosureGroup(
            content: {
                if !convertedText.string.isEmpty {
                    Text(.init(convertedText))
                }
            },
            label: {
                VStack (alignment: .leading){
                    
                    Text(subtitleText.string)
                    
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
                    subtitleText = convertHTML(infoLink.subtitle) ?? NSAttributedString(string: "")
                    convertedText = convertHTML(infoLink.content) ?? NSAttributedString(string: "")
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
