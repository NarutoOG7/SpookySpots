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
        
    @Published var srchcText = ""
    
    @Published var locations: [Location] = []
    @Published var favoriteLocations: [Location] = []
    @Published var hauntedHotels: [Location] = [] 
    @Published var onMapLocations: [Location] = [] {
        willSet {
            print(newValue.last!)
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
                print(newValue!.name)
            }
        }
    }
}
