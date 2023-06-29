//
//  ContentView.swift
//  Location
//
//  Created by Jan Hovland on 28/06/2023.
//

import SwiftUI
import CoreLocation

var latitude : Double = 0.00
var longitude : Double = 0.00
///
/// Globale variabler
///
struct ContentView: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    @State private var localLatitude: Double = 0.00
    @State private var localLongitude: Double = 0.00

    var body: some View {
        VStack {
            Spacer()
            ///
            /// Problem med Text og global verdi hvis ikke Text med @State skrives ut
            ///
            Text("Latitude global = \(latitude) Longitude global = \(longitude)")
            Text("Latitude @State = \(localLatitude) Longitude @State = \(localLongitude)")
            Spacer()
        }
        .task {
            // self.locationsHandler.startLocationUpdates()
            var value: (Double, Double)
            value = await FindLocalPosition()
            localLatitude = value.0
            localLongitude = value.1
            latitude = value.0
            longitude = value.1
            print("\(latitude) \(longitude)")
        }
    }
}

@MainActor func FindLocalPosition() async -> (Double, Double) {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    var lat: Double = 0.00
    var lon: Double = 0.00
    do {
        let updates = CLLocationUpdate.liveUpdates()
        for try await update in updates {
            if let loc = update.location {
                let lastLocation = loc
                if lastLocation.coordinate.latitude != 0.00 {
                    lat = lastLocation.coordinate.latitude
                    lon = lastLocation.coordinate.longitude
                    break
                }
            }
        }
    } catch {
        debugPrint(error)
    }
    return (lat, lon)
}
