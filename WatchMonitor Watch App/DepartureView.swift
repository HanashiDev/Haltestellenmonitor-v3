//
//  DepartureView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct DepartureView: View {
    var stop: Stop
    @State private var searchText = ""
    @State private var departureM: DepartureMonitor? = nil
    @State private var isLoaded = false

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { departure in
                    NavigationLink {
                        SingleTripView(stop: stop, departure: departure)
                    } label: {
                        DepartureRow(departure: departure)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stop.name)
        .onAppear {
            Task {
                await getDeparture()
            }
        }
    }
    
    var searchResults: [Departure] {
        let departures = departureM?.Departures ?? []
        
        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }
    
    func getDeparture() async {
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest(stopid: String(stop.stopId)))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")
        
        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            self.departureM = try decoder.decode(DepartureMonitor.self, from: content)
            isLoaded = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                Task {
                    await getDeparture()
                }
            }
        } catch {
            print(error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    await getDeparture()
                }
            }
        }
    }
}

struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartureView(stop: stops[0])
        }
    }
}
