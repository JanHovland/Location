//
//  ContentView.swift
//  Location
//
//  Created by Jan Hovland on 28/06/2023.
//

import SwiftUI

///
/// Globale variabler
///
var latitude: Double = 0.00
var longitude: Double = 0.00

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

