//
//  LocationStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

class LocationStore: ObservableObject {
    static let instance = LocationStore()
    
    let tripLocationsExample = [
        Location(id: 1231, name: "Armstrong Hotel"),
        Location(id: 1232, name: "Stanley Hotel"),
        Location(id: 1233, name: "Grand Union Hotel"),
        Location(id: 1234, name: "Sacajawea Hotel"),
        Location(id: 1235, name: "Hotel Occidental")
    ]
    
    @Published var locations: [Location] = []
    @Published var hauntedHotels: [Location] = []
    @Published var onMapLocations: [Location] = [] {
        willSet {
            print(newValue.last)
        }
    }
    @Published var nearbyLocations: [Location] = []
    @Published var everyFavoritedLocation: [FavoriteLocation] = []
    @Published var trendingLocations: [Location] = []
    @Published var selectedLocation: Location? {
        willSet {
            if newValue != nil {
                UserLocationManager.instance.getDistanceToLocation(location: newValue!) { distance in
                    UserStore.instance.selectedLocationDistanceToUser = distance
                }
            }
            
        }
    }
}
