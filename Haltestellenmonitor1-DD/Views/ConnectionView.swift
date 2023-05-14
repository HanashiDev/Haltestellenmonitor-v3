//
//  ConnectionView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    @State var day = ""
    @State var showingSheet = false
    @State var showingAlert = false
    @State var dateTime = Date.now
    @State var trip: Trip? = nil
    @State var isLoading = false
    @State private var requestData: TripRequest?
    @State private var numberprev = 0
    @State private var numbernext = 0
    @StateObject var filter: ConnectionFilter = ConnectionFilter()
    @StateObject var departureFilter = DepartureFilter()

    var body: some View {
        NavigationStack(path: $stopManager.presentedStops) {
            VStack {
                Form {
                    Section {
                        HStack {
                            HStack {
                                Text("Startpunkt")
                                    .lineLimit(1)
                                Spacer()
                                Text(filter.startStop == nil ? "Keine Auswahl" : filter.startStop?.displayName ?? "Keine Auswahl")
                                    .foregroundColor(Color.gray)
                                    .lineLimit(1)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                filter.start = true
                                showingSheet = true
                            }

                            Button {
                                locationManager.requestCurrentLocationComplete {
                                    filter.startStop = ConnectionStop(displayName: stops[0].getFullName(), stop: stops[0])
                                }
                            } label: {
                                Image(systemName: "location")
                            }
                        }

                        HStack {
                            HStack {
                                Text("Zielpunkt")
                                    .lineLimit(1)
                                Spacer()
                                Text(filter.endStop == nil ? "Keine Auswahl" : filter.endStop?.displayName ?? "Keine Auswahl")
                                    .foregroundColor(Color.gray)
                                    .lineLimit(1)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                filter.start = false
                                showingSheet = true
                            }

                            Button {
                                locationManager.requestCurrentLocationComplete {
                                    filter.endStop = ConnectionStop(displayName: stops[0].getFullName(), stop: stops[0])
                                }
                            } label: {
                                Image(systemName: "location")
                            }
                        }
                        
                        DisclosureGroup("Verkehrsmittel") {
                            DepartureDisclosureSection()
                        }
                        
                        HStack {
                            DatePicker("Zeit", selection: $dateTime)
                            Button {
                                dateTime = Date.now
                            } label: {
                                Text("Jetzt")
                            }
                        }
                        
                        Button {
                            Task {
                                if isLoading {
                                    return
                                }
                                isLoading = true
                                await createRequestData()
                                await getTripData()
                            }
                        } label: {
                            Text("Verbindungen anzeigen")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if (trip?.Routes != nil) {
                        ForEach(trip?.Routes ?? [], id: \.self) { route in
                            TripSection(route: route)
                        }
                        
                        Button {
                            if isLoading || requestData == nil || self.trip == nil {
                                return
                            }
                            isLoading = true
                            numbernext = numbernext + 1
                            
                            requestData!.sessionId = self.trip!.SessionId
                            requestData!.numberprev = 0
                            requestData!.numbernext = numbernext
                            
                            Task {
                                await getTripData(isNext: true)
                            }
                        } label: {
                            Text("später")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .sheet(isPresented: $showingSheet, content: {
                    ConnectionStopSelectionView()
                })
            }
            .navigationTitle("🏘️ Verbindungen")
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
    
    func createRequestData() async {
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
            mot.append("PlusBus")
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
        
        async let startStrPromise = filter.startStop!.getDestinationString()
        async let endStrPromise = filter.endStop!.getDestinationString()
        
        let startStr = await startStrPromise
        let endStr = await endStrPromise
        
        requestData = TripRequest(time: dateTime.ISO8601Format(), origin: startStr, destination: endStr, standardSettings: standardSettings)
    }
    
    func getTripData(isNext: Bool = false) async {
        if requestData == nil {
            return
        }

        var url = URL(string: "https://webapi.vvo-online.de/tr/trips")!
        if isNext {
            url = URL(string: "https://webapi.vvo-online.de/tr/prevnext")!
        }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestData)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            self.trip = try decoder.decode(Trip.self, from: content)

            isLoading = false
        } catch {
            isLoading = false
            print ("error: \(error)")
            await getTripData()
        }
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(trip: tripTmp)
            .environmentObject(LocationManager())
            .environmentObject(StopManager())
    }
}
