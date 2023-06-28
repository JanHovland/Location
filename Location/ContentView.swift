//
//  ContentView.swift
//  Location
//
//  Created by Jan Hovland on 28/06/2023.
//

import SwiftUI
import os
import CoreLocation

///
/// Globale variabler
///
var latitude: Double = 0.00
var longitude: Double = 0.00

@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    private let manager: CLLocationManager
    @Published
    var lastLocation = CLLocation()
    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }
    
    private init() {
        self.manager = CLLocationManager()
    }
    
    func startLocationUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
        Task() {
            do {
                self.updatesStarted = true
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !self.updatesStarted { break }
                    if let loc = update.location {
                        self.lastLocation = loc
                        if self.lastLocation.coordinate.latitude != 0.00 {
                            ///
                            /// Oppdaterer de globale variablene
                            ///
                            latitude = self.lastLocation.coordinate.latitude
                            longitude = self.lastLocation.coordinate.longitude
                            self.updatesStarted = false
                        }
                    }
                }
            } catch {
                debugPrint(error)
            }
            return
        }
    }
}

struct ContentView: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(latitude) \(longitude)")
            Spacer()
        }
        .onAppear {
            self.locationsHandler.startLocationUpdates()
        }
    }
}

