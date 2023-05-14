//
//  ConnectionStopSelectionView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI
import CoreLocation
import Contacts

struct ConnectionStopSelectionView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoriteStops: FavoriteStop
    @EnvironmentObject var filter: ConnectionFilter
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var placemarks: [CLPlacemark] = []
    @State private var location: CLLocation?
    @State private var addressString = ""
    @State private var showPicker = false
    
    @State private var showNoAddressAlert = false
    @State private var contactName = ""
    @State private var addresses: [CNLabeledValue<CNPostalAddress>] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if addressString != "" {
                        HStack {
                            Text("🏘️ \(addressString)")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if (filter.start) {
                                filter.startStop = ConnectionStop(displayName: addressString, location: location)
                            } else {
                                filter.endStop = ConnectionStop(displayName: addressString, location: location)
                            }
                            dismiss()
                        }
                    }
                    HStack {
                        if contactName != "" {
                            Text("📒 \(contactName)")
                        } else {
                            Text("📒 Kontakt auswählen")
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPicker.toggle()
                    }
                }
                if addresses.count > 0 {
                    Section(header: Text("Kontakt-Adressen")) {
                        List(addresses, id: \.self) { labeledAddress in
                            HStack {
                                Text("\(labeledAddress.value.street), \(labeledAddress.value.postalCode) \(labeledAddress.value.city)")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectContactAddress(address: labeledAddress.value)
                            }
                        }
                    }
                }
                Section(header: Text("Haltestellen")) {
                    List(searchResults, id: \.self) { stop in
                        StopRow(stop: stop)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if (filter.start) {
                                    filter.startStop = ConnectionStop(displayName: stop.getFullName(), stop: stop)
                                } else {
                                    filter.endStop = ConnectionStop(displayName: stop.getFullName(), stop: stop)
                                }
                                dismiss()
                            }
                    }
                }
            }
            .navigationTitle(filter.start ? "🏠 Startpunkt" : "🏠 Zielpunkt")
            .searchable(text: $searchText, placement:.navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button {
                        locationManager.requestCurrentLocation()
                    } label: {
                        Label("", systemImage: "location")
                    }
                }
            }
        }
        .dynamicTypeSize(.medium ... .large)
        .task(id: searchText) {
            changePlace()
        }
        .alert("Bei diesem Kontakt ist keine Adresse hinterlegt.", isPresented: $showNoAddressAlert) {
            Button {
                // do nothing
            } label: {
                Text("OK")
            }
        }
        .sheet(isPresented: $showPicker) {
            ContactPicker { result in
                switch result {
                case .selectedContact(let contact):
                    selectContact(contact: contact)
                case .cancelled:
                    // Handle cancellation
                    break
                }
            }
                .dynamicTypeSize(.medium ... .large)
        }
    }
    
    var searchResults: [Stop] {
        stops = stops.sorted {
            $0.distance ?? 0 < $1.distance ?? 0
        }
        
        var newStops: [Stop] = []
        stops.forEach { stop in
            if (favoriteStops.isFavorite(stopID: stop.stopId)) {
                newStops.append(stop)
            }
        }
        stops.forEach { stop in
            if (!favoriteStops.isFavorite(stopID: stop.stopId)) {
                newStops.append(stop)
            }
        }
        stops = newStops
        
        if searchText.isEmpty {
            return stops
        } else {
            return stops.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func selectContactAddress(address: CNPostalAddress) {
        let addressStr = "\(address.street), \(address.postalCode) \(address.city)"
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressStr) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                return
            }
            
            if (filter.start) {
                filter.startStop = ConnectionStop(displayName: contactName, location: location)
            } else {
                filter.endStop = ConnectionStop(displayName: contactName, location: location)
            }
            dismiss()
        }
    }
    
    func changePlace() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                return
            }
            
            self.placemarks = placemarks
            self.location = location
            
            if placemarks.first != nil {
                addressString = "\(placemarks.first?.name ?? ""), \(placemarks.first?.postalCode ?? "") \(placemarks.first?.locality ?? "")"
            } else {
                addressString = ""
            }
        }
    }
    
    func selectContact(contact: CNContact) {
        if contact.givenName == "" && contact.familyName == "" && contact.organizationName != "" {
            contactName = contact.organizationName
        } else {
            contactName = "\(contact.givenName) \(contact.familyName)"
        }
        
        if contact.postalAddresses.count <= 0 {
            addresses = []
            showNoAddressAlert.toggle()
            return
        }
        
        if contact.postalAddresses.count == 1 {
            selectContactAddress(address: contact.postalAddresses.first!.value)
            return
        }

        addresses = contact.postalAddresses
    }
}

struct ConnectionStopSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStopSelectionView()
            .environmentObject(LocationManager())
            .environmentObject(FavoriteStop())
            .environmentObject(ConnectionFilter())
    }
}
