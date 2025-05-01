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
                    }
                }

                Section(header: Text("Kontakt")) {
                    Link(destination: URL(string: "mailto:info@hanashi.dev?subject=Haltestellenmonitor%20Dresden%20Feedback")!) {
                        Text(verbatim: "📧 info@hanashi.dev")
                    }
                    Link(destination: URL(string: "https://hanashi.dev")!) {
                        Text(verbatim: "🌍 Homepage")
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
