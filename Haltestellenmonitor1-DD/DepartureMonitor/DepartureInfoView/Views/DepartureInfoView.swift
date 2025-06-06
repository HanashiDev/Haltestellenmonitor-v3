//
//  DepartureInfoView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.03.25.
//

import Foundation
import SwiftUI

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

// struct DepartureInfoPreview: PreviewProvider {
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
// }
