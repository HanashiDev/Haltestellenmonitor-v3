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
                    Link("📧 info@hanashi.dev", destination: URL(string: "mailto:info@hanashi.dev?subject=Haltestellenmonitor%20Dresden%20Feedback")!)
                    Link("🌍 Homepage", destination: URL(string: "https://hanashi.dev")!)
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
