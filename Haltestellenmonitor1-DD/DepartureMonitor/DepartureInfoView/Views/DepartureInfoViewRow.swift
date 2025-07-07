//
//  DepartureInfoViewRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.05.25.
//

import SwiftUI

struct DepartureInfoViewRow: View {
    let infoLink: InfoLink
    @Binding var isExpanded: Bool
    @State private var convertedText: [[stringSection]] = []
    @State private var subtitleText: String = ""

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
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
                                    .accessibilityHidden(true)

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
                VStack(alignment: .leading) {

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
