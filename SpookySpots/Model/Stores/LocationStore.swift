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
    
    @Published var locations: [LocationModel] = []
    @Published var favoriteLocations: [LocationModel] = []
    @Published var hauntedHotels: [LocationModel] = []
    @Published var onMapLocations: [LocationModel] = [] {
        willSet {
            print(newValue.count)
        }
    }
    @Published var nearbyLocations: [LocationModel] = []
    @Published var everyFavoritedLocation: [FavoriteLocation] = []
    @Published var trendingLocations: [LocationModel] = []
    @Published var selectedLocation: LocationModel? {
        willSet {
            if newValue != nil {
                UserLocationManager.instance.getDistanceToLocation(location: newValue!) { distance in
                    UserStore.instance.selectedLocationDistanceToUser = distance
                }
                print(newValue!.location.name)
            }
        }
    }
}
