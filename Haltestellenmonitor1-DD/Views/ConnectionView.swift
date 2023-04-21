//
//  ConnectionView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var stopManager: StopManager
    @State var day = ""
    @State var showingSheet = false
    @State var showingAlert = false
    @State var dateTime = Date.now
    @State var trip: Trip? = nil
    @State var isLoading = false
    @StateObject var filter: ConnectionFilter = ConnectionFilter()
    @StateObject var departureFilter = DepartureFilter()

    var body: some View {
        NavigationStack(path: $stopManager.presentedStops) {
            VStack {
                Form {
                    Section {
                        HStack {
                            Text("Startpunkt")
                                .lineLimit(1)
                            Spacer()
                            Text(filter.startStop == nil ? "Keine Auswahl" : filter.startStop?.name ?? "")
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            filter.start = true
                            showingSheet = true
                        }

                        HStack {
                            Text("Zielpunkt")
                                .lineLimit(1)
                            Spacer()
                            Text(filter.endStop == nil ? "Keine Auswahl" : filter.endStop?.name ?? "")
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            filter.start = false
                            showingSheet = true
                        }
                        
                        DisclosureGroup("Verkehrsmittel") {
                            DepartureDisclosureSection()
                        }
                        
                        DatePicker("Zeit", selection: $dateTime)
                        
                        Button {
                            getTripData()
                        } label: {
                            Text("Verbindungen anzeigen")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if (trip?.Routes != nil) {
                        ForEach(trip?.Routes ?? [], id: \.self) { route in
                            TripSection(route: route)
                        }
                    }
                }
                .sheet(isPresented: $showingSheet, content: {
                    ConnectionStopSelectionView()
                })
            }
            .navigationTitle("Verbindungen")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    if (isLoading) {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button("Zurücksetzen") {
                        if (isLoading) {
                            return
                        }
                        filter.startStop = nil
                        filter.endStop = nil
                        dateTime = Date.now
                    }
                }
            }
            .alert("Es muss ein Start- und Endziel ausgewählt werden", isPresented: $showingAlert) {
                Button {
                    isLoading = false
                } label: {
                    Text("OK")
                }
            }
            .navigationDestination(for: Stop.self) { stop in
                DepartureView(stop: stop)
            }
        }
        .environmentObject(filter)
        .environmentObject(departureFilter)
    }
    
    func getTripData() {
        if (isLoading) {
            return
        }
        isLoading = true
        if (filter.startStop == nil || filter.endStop == nil) {
            showingAlert = true
            return
        }
        
        var mot: [String] = []
        if (departureFilter.tram) {
            mot.append("Tram")
        }
        if (departureFilter.bus) {
            mot.append("CityBus")
            mot.append("IntercityBus")
        }
        if (departureFilter.suburbanRailway) {
            mot.append("SuburbanRailway")
        }
        if (departureFilter.train) {
            mot.append("Train")
        }
        if (departureFilter.cableway) {
            mot.append("Cableway")
        }
        if (departureFilter.ferry) {
            mot.append("Ferry")
        }
        if (departureFilter.taxi) {
            mot.append("HailedSharedTaxi")
        }
        
        let standardSettings = TripStandardSettings(mot: mot)
        
        let requestData = TripRequest(time: dateTime.ISO8601Format(), origin: String(filter.startStop?.stopId ?? 0), destination: String(filter.endStop?.stopId ?? 0), standardSettings: standardSettings)
        
        let url = URL(string: "https://webapi.vvo-online.de/tr/trips")!
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestData)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print ("error: \(error!)")
                getTripData()
                return
            }

            guard let content = data else {
                print("No data")
                getTripData()
                return
            }


            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    self.trip = try decoder.decode(Trip.self, from: content)
                } catch {
                    print(error)
                    getTripData()
                }
                isLoading = false
            }

        }
        task.resume()
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(trip: tripTmp)
            .environmentObject(StopManager())
    }
}
