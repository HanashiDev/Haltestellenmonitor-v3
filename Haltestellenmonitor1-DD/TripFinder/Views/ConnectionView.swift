//
//  ConnectionView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI
import CoreLocation

private var buttonHeight: CGFloat = 38

struct ConnectionView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stopManager: StopManager
    @State var day = ""
    @State var showingSheet = false
    @State var showingAlert = false
    @State var showingAlertEqual = false
    @State var showingSaveAlert = false
    @State var dateTime = Date.now
    @State var isArrivalTime = 0 // false
    @State var trip: Trip?
    @State var isLoading = false
    @State private var requestData: TripRequest?
    @State private var numbernext = 0
    @State private var favoriteName = ""
    @StateObject var filter: ConnectionFilter = ConnectionFilter()
    @StateObject var departureFilter = DepartureFilter()
    @StateObject var favoriteConnections = FavoriteConnection()
    @State private var minDate = Date().addingTimeInterval(TimeInterval(-20.0 * 60.0)) // 20 minutes in past

    var body: some View {
        NavigationStack(path: $stopManager.presentedStops) {
            VStack(spacing: 5) {
                // .contentMargins(.vertical, 0)
                if #available(iOS 17.0, *) {
                    listView()
                        .listSectionSpacing(18)
                        .sheet(isPresented: $showingSheet, content: {
                            ConnectionStopSelectionView()
                        })
                } else {
                    listView()    .sheet(isPresented: $showingSheet, content: {
                        ConnectionStopSelectionView()
                    })
                }
            }
            .navigationTitle("🏘️ Verbindungen")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    if isLoading {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button("Zurücksetzen") {
                        if isLoading {
                            return
                        }
                        filter.startStop = nil
                        filter.endStop = nil
                        trip = nil
                        requestData = nil
                        numbernext = 0
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
            .alert("Start- und Endziel darf nicht gleich sein", isPresented: $showingAlertEqual) {
                Button {
                    isLoading = false
                } label: {
                    Text("OK")
                }
            }
            .alert("Wie soll der Favorit gespeichert werden?", isPresented: $showingSaveAlert) {
                TextField("Name", text: $favoriteName)
                Button {
                    saveFavorite()
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

    func listView() -> some View {
        Form {
            Section {
                if favoriteConnections.favorites.count > 0 {
                    DisclosureGroup("Favoriten") {
                        List(favoriteConnections.favorites, id: \.id) { favoriteConnection in
                            HStack {
                                Text(favoriteConnection.name)
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            favoriteConnections.remove(trip: favoriteConnection)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                                    .accessibilityLabel("Gespeicherte Verbindung:  \(favoriteConnection.name)")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showFavorite(favorite: favoriteConnection)
                            }
                            .accessibilityAddTraits(.isButton)
                        }
                    }.accessibilityHint("Gespeicherte Verbindungen")
                }
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
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)

                    Button {
                        locationManager.requestCurrentLocationComplete {
                            locationManager.lookUpCurrentLocation { placemark in
                                if placemark != nil {
                                    filter.startStop = ConnectionStop(displayName: "\(placemark?.name ?? ""), \(placemark?.postalCode ?? "") \(placemark?.locality ?? "")", location: StopCoordinate(latitude: locationManager.location?.latitude ?? 0, longitude: locationManager.location?.longitude ?? 0))
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                    .accessibilityLabel("Aktuellen Standort als Startpunkt setzen")
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
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)

                    Button {
                        locationManager.requestCurrentLocationComplete {
                            locationManager.lookUpCurrentLocation { placemark in
                                if placemark != nil {
                                    filter.endStop = ConnectionStop(displayName: "\(placemark?.name ?? ""), \(placemark?.postalCode ?? "") \(placemark?.locality ?? "")", location: StopCoordinate(latitude: locationManager.location?.latitude ?? 0, longitude: locationManager.location?.longitude ?? 0))
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                    .accessibilityLabel("Aktuellen Standort als Zielpunkt setzen")
                }

                DisclosureGroup("Verkehrsmittel") {
                    DepartureDisclosureSection()
                }

                VStack {
                    HStack {
                        DatePicker("Zeit", selection: $dateTime, in: minDate...)
                        Button {
                            dateTime = Date.now
                        } label: {
                            Text("Jetzt")
                                .accessibilityHint("Auf aktuellen Zeitpunkt zurücksetzen")
                        }
                    }
                    Picker("", selection: $isArrivalTime) {
                        Text("Abfahrt").tag(0)
                            .accessibilityHint("Die gewählte Zeit ist der Abfahrtszeitpunkt")
                        Text("Ankunft").tag(1)
                            .accessibilityHint("Die gewählte Zeit ist der Ankunftszeitpunkt")
                    }
                    .pickerStyle(.segmented)

                }
            }

            Section {
                HStack {
                    Button {
                        showingSaveAlert.toggle()
                    } label: {
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }.frame(width: 50, height: buttonHeight)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor { traitCollection in
                            return traitCollection.userInterfaceStyle == .dark ?
                                .systemGray5 :
                                .systemBackground
                        })))
                        .disabled(filter.startStop != nil && filter.endStop != nil ? false : true)
                        .accessibilityLabel("Verbindung als Favorit speichern")

                    Spacer()

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
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .frame(height: buttonHeight)
                    // .disabled(filter.startStop != nil && filter.endStop != nil ? false : true)
                }.buttonStyle(BorderlessButtonStyle()) // used so the hitbox of the buttons is correct
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove padding
            }.listRowBackground(Color.clear)

            if trip?.Routes != nil {
                /*Button {
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
                    Text("Frühere Verbindungen")
                }
                .frame(maxWidth: .infinity)*/

                ForEach(trip?.Routes ?? [], id: \.self) { route in
                    TripSection(vm: TripSectionViewModel(route: route))
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
                    Text("Spätere Verbindungen")
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    func createRequestData() async {
        if filter.startStop == nil || filter.endStop == nil {
            showingAlert = true
            return
        }
        let standardSettings = getStandardSettings()

        async let startStrPromise = filter.startStop!.getDestinationString()
        async let endStrPromise = filter.endStop!.getDestinationString()

        let startStr = await startStrPromise
        let endStr = await endStrPromise

        requestData = TripRequest(time: dateTime.ISO8601Format(), isarrivaltime: isArrivalTime == 1, origin: startStr, destination: endStr, standardSettings: standardSettings)
    }

    func getTripData(isNext: Bool = false) async {
        if requestData == nil {
            return
        }
        // prevent errors
        if requestData!.origin == requestData!.destination {
            showingAlertEqual = true
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
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            numbernext = 0
            self.trip = try decoder.decode(Trip.self, from: content)

            isLoading = false
        } catch {
            print("error: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    await getTripData(isNext: isNext)
                }
            }
        }
    }

    func getStandardSettings() -> TripStandardSettings {
        var mot: [String] = []
        if departureFilter.tram {
            mot.append("Tram")
        }
        if departureFilter.bus {
            mot.append("CityBus")
            mot.append("IntercityBus")
            mot.append("PlusBus")
        }
        if departureFilter.suburbanRailway {
            mot.append("SuburbanRailway")
        }
        if departureFilter.train {
            mot.append("Train")
        }
        if departureFilter.cableway {
            mot.append("Cableway")
        }
        if departureFilter.ferry {
            mot.append("Ferry")
        }
//        if (departureFilter.taxi) {
//            mot.append("HailedSharedTaxi")
//        }

        return TripStandardSettings(mot: mot)
    }

    func saveFavorite() {
        let standardSettings = getStandardSettings()

        if filter.startStop == nil || filter.endStop == nil {
            return
        }

        if favoriteName.isEmpty {
            favoriteName = "Standard"
        }

        let requestShort = TripRequestShort(name: favoriteName, origin: filter.startStop!, destination: filter.endStop!, standardSettings: standardSettings)

        favoriteName = ""

        favoriteConnections.add(trip: requestShort)
    }

    func showFavorite(favorite: TripRequestShort) {
        filter.startStop = favorite.origin
        filter.endStop = favorite.destination

        departureFilter.tram = false
        departureFilter.bus = false
        departureFilter.suburbanRailway = false
        departureFilter.train = false
        departureFilter.cableway = false
        departureFilter.ferry = false
//        departureFilter.taxi = false

        let mots = favorite.standardSettings?.mot ?? []
        for mot in mots {
            switch mot {
            case "Tram":
                departureFilter.tram = true
                case "CityBus":
                departureFilter.bus = true
                case "IntercityBus":
                departureFilter.bus = true
                case "PlusBus":
                departureFilter.bus = true
                case "SuburbanRailway":
                departureFilter.suburbanRailway = true
                case "Train":
                departureFilter.train = true
                case "Cableway":
                departureFilter.cableway = true
                case "Ferry":
                departureFilter.ferry = true
//            case "HailedSharedTaxi":
//                departureFilter.taxi = true
//                break
            default:
                break
            }
        }

        dateTime = Date.now

        Task {
            if isLoading {
                return
            }
            isLoading = true
            await createRequestData()
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
