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
    @State var isArrivalTime = false // false
    @State var trip: Trip?
    @State var isLoading = false
    @State private var requestData: TripRequestJSON?
    @State private var numbernext = 0
    @State private var favoriteName = ""
    @StateObject var filter: ConnectionFilter = ConnectionFilter()
    @StateObject var departureFilter = DepartureFilter()
    @StateObject var favoriteConnections = FavoriteConnection()
    @State private var minDate = Date().addingTimeInterval(TimeInterval(-20.0 * 60.0)) // 20 minutes in past

    @AppStorage("trip_individualTransportType")
    private var individualTransportType: IndividualTransportType = .walking

    @AppStorage("trip_showFare")
    private var showFare: Bool = true

    @AppStorage("trip_showOneBefore")
    private var showOneBefore: Bool = true

    @AppStorage("trip_individualTransportSpeed")
    private var indiviudalTransportSpeed: IndividualTransportSpeed = .normal

    @AppStorage("trip_useWheelchair")
    private var useWheelchair: Bool = false

    @AppStorage("trip_noStairs")
    private var noStairs: Bool = false

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
                    listView()
                        .sheet(isPresented: $showingSheet, content: {
                            ConnectionStopSelectionView()
                        })
                }
            }
            .navigationTitle("🏘️ Verbindungen")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            filter.startStop = nil
                            filter.endStop = nil
                            trip = nil
                            requestData = nil
                            numbernext = 0
                            dateTime = Date.now
                        } label: {
                            Text(Image(systemName: "arrow.counterclockwise"))
                        }
                    }
                }

                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    NavigationLink {
                        TripSettingsView()
                    } label: {
                        Text(Image(systemName: "gearshape"))
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
            HStack {
                Section {
                    VStack(alignment: .leading) {
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

                            Image(systemName: "location").onTapGesture {
                                locationManager.requestCurrentLocationComplete {
                                    locationManager.lookUpCurrentLocation { placemark in
                                        if placemark != nil {
                                            filter.startStop = ConnectionStop(displayName: "\(placemark?.name ?? ""), \(placemark?.postalCode ?? "") \(placemark?.locality ?? "")", location: StopCoordinate(latitude: locationManager.location?.latitude ?? 0, longitude: locationManager.location?.longitude ?? 0))
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel("Aktuellen Standort als Startpunkt setzen")
                        }

                        Divider()

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

                            Image(systemName: "arrow.up.arrow.down")
                                .onTapGesture {
                                    switchStops()
                                }
                                .foregroundStyle(Color.accentColor)
                                .accessibilityLabel("Starpunkt und Zielpunkt vertauschen")
                        }
                    }
                }
                .frame(maxWidth: .infinity) // Make the section take available space

                /* // TODO: uncomment when in-between stops implemented
                Image(systemName: "plus.circle")
                    .onTapGesture {
                        // TODO: implement add in-between-stop
                        print("add stop")
                    }
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Zischenstop hinzufügen")
                 */
            }

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
                        Text("Abfahrt").tag(false)
                            .accessibilityHint("Die gewählte Zeit ist der Abfahrtszeitpunkt")
                        Text("Ankunft").tag(true)
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
                            .foregroundStyle(Color(UIColor { traitCollection in
                                if traitCollection.userInterfaceStyle == .dark {
                                    return .systemGray6
                                } else {
                                    return .white
                                }
                            }
                        ))
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .frame(height: buttonHeight)

                    // .disabled(filter.startStop != nil && filter.endStop != nil ? false : true)
                }.buttonStyle(BorderlessButtonStyle()) // used so the hitbox of the buttons is correct
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove padding
            }.listRowBackground(Color.clear)

            if trip?.journeys != nil {
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

                ForEach(trip?.journeys ?? [], id: \.self) { journey in
                    TripSection(vm: TripSectionViewModel(journey: journey))
                }

                Button {
                    if isLoading || requestData == nil || self.trip == nil {
                        return
                    }
                    isLoading = true
                    numbernext = numbernext + 1

//                    requestData!.numberprev = 0
//                    requestData!.numbernext = numbernext

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

    func switchStops() {
        let stop1 = filter.endStop
        filter.endStop = filter.startStop
        filter.startStop = stop1
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

        requestData = TripRequestJSON(itdTime: getTimeStampURL(date: dateTime), itdDate: getDateStampURL(date: dateTime), origin: startStr, destination: endStr, individualTransportType: individualTransportType, indiviualTransportSpeed: indiviudalTransportSpeed, excludeTransports: standardSettings, isarrivaltime: isArrivalTime, useWheelchair: useWheelchair, noStairs: noStairs, showOneBefore: showOneBefore)
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

        let url = URL(string: "https://efa.vvo-online.de/std3/trias/XML_TRIP_REQUEST2")!
//        if isNext {
//            url = URL(string: "https://webapi.vvo-online.de/tr/prevnext")!
//        }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = requestData?.createTripRequestString().data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Haltestellenmonitor Dresden v2", forHTTPHeaderField: "User-Agent")

        do {
            let (content, _) = try await URLSession.shared.data(for: request)

            numbernext = 0
            do {
                let t = try JSONDecoder().decode(Trip.self, from: content)
                await MainActor.run {
                    self.trip = t
                    isLoading = false
                }
            } catch {
                if let jsonString = String(data: content, encoding: .utf8) {
                    print("Trip Finder JSON DECODE error: \(error)\n\n\(jsonString)")
                }
            }

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
            mot.append("4")
        }
        if departureFilter.bus {
            mot.append("5")
            mot.append("6")
        }
        if departureFilter.suburbanRailway {
            mot.append("3")
            // TODO Maybe add more here?
        }
        if departureFilter.train {
            mot.append("0")
        }
        if departureFilter.cableway {
            mot.append("8")
        }
        if departureFilter.ferry {
            mot.append("9")
        }

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

        let mots = favorite.standardSettings?.mot ?? []
        for mot in mots {
            switch mot {
                case "4":
                    departureFilter.tram = true
                case "5":
                    departureFilter.bus = true
                case "6":
                    departureFilter.bus = true
                case "3":
                    departureFilter.suburbanRailway = true
                case "0":
                    departureFilter.train = true
                case "8":
                    departureFilter.cableway = true
                case "9":
                    departureFilter.ferry = true
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
