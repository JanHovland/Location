//
//  ContentView.swift
//  Location
//
//  Created by Jan Hovland on 28/06/2023.
//

import SwiftUI

import os
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    var body: some View {
        VStack {
            Spacer()
            Text("Location: \(locationsHandler.lastLocation.coordinate.latitude) \(locationsHandler.lastLocation.coordinate.longitude)")
                .padding(10)
            Spacer()
        }
        .onAppear {
            self.locationsHandler.startLocationUpdates()
        }
    }
}


#Preview {
    ContentView()
}

@MainActor class LocationsHandler: ObservableObject {
    let logger = Logger(subsystem: "com.janHovland.liveUpdatesSample", category: "LocationsHandler")
    
    static let shared = LocationsHandler()  // Create a single, shared instance of the object.

    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?

    @Published var lastLocation = CLLocation()

    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }
    
    private init() {
        self.manager = CLLocationManager()  // Creating a location manager instance is safe to call here in `MainActor`.

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
                    if !self.updatesStarted { break }  // End location updates by breaking out of the loop.
                    if let loc = update.location {
                        self.lastLocation = loc
                        if self.lastLocation.coordinate.latitude != 0.00 {
                            stopLocationUpdates()
                        }
                    }
                }
            } catch {
                self.logger.error("Could not start location updates")
            }
            return
        }
    }
    
    func stopLocationUpdates() {
        self.updatesStarted = false
    }
}
