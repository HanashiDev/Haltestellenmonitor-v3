//
//  DepartureView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct DepartureView: View {
    var stop: Stop
    @EnvironmentObject var favoriteStops: FavoriteStop
    @State var departureM: DepartureMonitor? = nil
    @State private var searchText = ""
    @State private var isLoaded = false
    @State private var dateTime = Date.now
    @State private var topExpanded: Bool = true
    @StateObject var departureFilter = DepartureFilter()
    
    var body: some View {
        Group {
            if (isLoaded) {
                VStack {
                    Form {
                        Section {
                            DisclosureGroup("Verkehrsmittel") {
                                DepartureDisclosureSection()
                            }
                            DatePicker("Zeit", selection: $dateTime)
                        }
                        Section {
                            List(searchResults, id: \.self) { departure in
                                ZStack {
                                    NavigationLink {
                                        SingleTripView(stop: stop, departure: departure)
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0.0)
                                    .buttonStyle(.plain)
                                    
                                    DepartureRow(departure: departure)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .refreshable {
            getDeparture()
        }
        .navigationTitle(stop.name)
        .toolbar {
            Button {
                if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                    favoriteStops.remove(stopID: stop.stopId)
                } else {
                    favoriteStops.add(stopID: stop.stopId)
                }
            } label: {
                if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                    Label("", systemImage: "star.fill")
                } else {
                    Label("", systemImage: "star")
                }
            }
        }
        .task(id: stop.stopId) {
            departureM = nil
            isLoaded = false
            getDeparture()
        }
        .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
        .onChange(of: dateTime) { newValue in
            getDeparture(time: newValue.ISO8601Format())
        }
        .environmentObject(departureFilter)
    }
    
    var searchResults: [Departure] {
        var departures = departureM?.Departures ?? []
        departures = departures.filter {
            departureFilter.tram && $0.Mot == "Tram" ||
            departureFilter.bus && ($0.Mot == "CityBus" || $0.Mot == "IntercityBus") ||
            departureFilter.suburbanRailway && $0.Mot == "SuburbanRailway" ||
            departureFilter.train && $0.Mot == "Train" ||
            departureFilter.cableway && $0.Mot == "Cableway" ||
            departureFilter.ferry && $0.Mot == "Ferry" ||
            departureFilter.taxi && $0.Mot == "HailedSharedTaxi"
        }
        
        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }
    
    // TODO: View aller 30 Sekunden aktualisieren
    func getDeparture(time: String? = nil) {
        let url = URL(string: "https://webapi.vvo-online.de/dm")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DepartureRequest(stopid: String(stop.stopId), time: time))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                getDeparture(time: time)
                return
            }

            guard let content = data else {
                print("No data")
                getDeparture(time: time)
                return
            }


            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    self.departureM = try decoder.decode(DepartureMonitor.self, from: content)
                    isLoaded = true
                } catch {
                    print(error)
                    getDeparture(time: time)
                }
            }

        }
        task.resume()
    }
}

struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartureView(stop: stops[1])
        }.environmentObject(FavoriteStop())
    }
}
