//
//  Contact.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import SwiftUI

struct About: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App-Information")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unbekannt") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unbekannt"))")
                    }.accessibilityElement(children: .combine)
                }

                Section(header: Text("Kontakt")) {
                    Link(destination: URL(string: "mailto:info@hanashi.dev?subject=Haltestellenmonitor%20Dresden%20Feedback")!) {
                        Text(verbatim: "📧 info@hanashi.dev")
                            .accessibilityHint("Email an den App-Entwickler schicken")
                    }
                    Link(destination: URL(string: "https://hanashi.dev")!) {
                        Text(verbatim: "🌍 Homepage")
                    }
                    Link(destination: URL(string: "https://github.com/HanashiDev/Haltestellenmonitor-v3")!) {
                        HStack {
                            Image("GitHubIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .offset(x: 1)
                            Text(verbatim: "GitHub")
                                .offset(x: -1)

                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("GitHub Repository mit Quellcode zur App aufrufen")
                    }
                }
            }
            .navigationTitle("Über")
        }
    }
}

struct Contact_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
