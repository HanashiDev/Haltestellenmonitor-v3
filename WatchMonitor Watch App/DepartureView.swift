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
    @State private var stopEvents: [StopEvent] = []
    @State private var isLoaded = false

    var body: some View {
        Group {
            if (isLoaded) {
                List(searchResults, id: \.self) { stopEvent in
                    NavigationLink {
                        SingleTripView(stop: stop, stopEvent: stopEvent)
                    } label: {
                        DepartureRow(stopEvent: stopEvent)
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
    
    var searchResults: [StopEvent] {
        let departures = stopEvents

        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }
    
    func getDeparture() async {
        let url = URL(string: "https://efa.vvo-online.de/std3/trias")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = DepartureRequest(stopPointRef: stop.gid).getXML()
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        do {
            let (content, _) = try await URLSession.shared.data(for: request)
            let serviceParser = StopEventResponseParser(data: content)
            serviceParser.parse()
            self.stopEvents = serviceParser.stopEvents
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
