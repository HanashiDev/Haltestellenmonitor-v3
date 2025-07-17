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
    @Binding var selectedDetent: PresentationDetent
    @State var expandedRows: Set<Int> = []

    private var anyRowExpanded: Bool {
        !expandedRows.isEmpty
    }

    var body: some View {
        // only use after check for stopEvent.infos exists
        Group {
            VStack {
                Spacer(minLength: 20)
                List(Array(stopEvent.infos!.enumerated()), id: \.offset) { bigIndex, info in
                    if #available(iOS 17.0, *) {
                        ForEach(Array(info.infoLinks.enumerated()), id: \.offset) { index, link in
                            DepartureInfoViewRow(
                                infoLink: link,
                                isExpanded: Binding(
                                    get: { expandedRows.contains(100 * bigIndex + index) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedRows.insert(100 * bigIndex + index)
                                        } else {
                                            expandedRows.remove(100 * bigIndex + index)
                                        }
                                    }
                                )
                            )
                        }
                        .onChange(of: anyRowExpanded) { _, expanded in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                                selectedDetent = expanded ?
                                PresentationDetent.large :
                                PresentationDetent.fraction(min(1.0, stopEvent.getInfosSize()))
                            }
                        }
                        .onChange(of: selectedDetent) {
                            /// minimize all expanded rows on sheet minimization
                            if selectedDetent != .large {
                                expandedRows.removeAll()
                            }
                        }
                    } else {
                        ForEach(Array(info.infoLinks.enumerated()), id: \.offset) { index, link in
                            DepartureInfoViewRow(
                                infoLink: link,
                                isExpanded: Binding(
                                    get: { expandedRows.contains(index) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedRows.insert(index)
                                        } else {
                                            expandedRows.remove(index)
                                        }
                                    }
                                )
                            )
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Meldungen für \(stopEvent.getName())")
    }
}

 struct DepartureInfoPreview: PreviewProvider {

    struct PreviewWrapper: View {
        @State var selectedDetent: PresentationDetent = .fraction(0.1 * 2.0)

         var body: some View {
             DepartureInfoView(
                stopEvent: StopEvent(
                    location: Location(
                        id: "de:14612:28",
                        name: "HBF DD",
                        disassembledName: "",
                        type: "stop",
                        coord: [],
                        properties: Stop_Property(stopId: "de:14612:28")
                    ),
                    departureTimePlanned: "2025-03-26T06:00:00Z",
                    departureTimeBaseTimetable: "2025-03-26T06:00:00Z",
                    transportation: Transportation(
                        id: "ddb:98X27: :R:j25",
                        number: "ICE 870",
                        product: Product(name: "Zug", iconId: 6),
                        properties: T_Properties(),
                        destination: Place(id: "", name: "", type: "")
                    ),
                    infos: [
                        Info(
                            priority: "Medium",
                            infoLinks: [
                                InfoLink(
                                    urlText: "",
                                    url: "",
                                    content: "Hallo Welt",
                                    subtitle: "hi"
                                )
                            ]
                        ),
                        Info(
                            priority: "Medium",
                            infoLinks: [
                                InfoLink(
                                    urlText: "",
                                    url: "",
                                    content:
                                        "Hallo Welt wie geht es dir heute mir geht es gut und dir auch? das hier ist jetzt ganz viel Text um die expansion weiter zu testen, wenn der Text länger ist soll nämlich die View weiter nach unten expandiert werden",
                                    subtitle: "hi",
                                    title: "Test"
                                ),
                                InfoLink(
                                    urlText: "",
                                    url: "",
                                    content:
                                        "<h1>Hallö Welt</h1><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>",
                                    subtitle: "hi",
                                    title: "Test2"
                                )
                            ]
                        )
                    ]
                ), selectedDetent: $selectedDetent
             )
         }
     }

    static var previews: some View {
        PreviewWrapper()
    }
 }
