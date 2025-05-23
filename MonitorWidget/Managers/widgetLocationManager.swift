//
//  widgetLocationManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 03.11.23
//  Credit to https://github.com/AKORA-Studios for helping with the LocationManager
//

import Foundation
import CoreLocation

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()

    private var completion: ((CLLocation) -> Void)?

    @Published var llocation: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        DispatchQueue.main.async {
            if self.locationManager.authorizationStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    func fetchLocation(completion: @escaping (CLLocation) -> Void) async {
        self.completion = completion
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        self.llocation = location

        if completion != nil {
            completion!(location)
            completion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("MonitorWidgetLocationManagerError ", error)
    }
}
