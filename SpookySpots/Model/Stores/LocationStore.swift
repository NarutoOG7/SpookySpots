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
            
    @Published var favoriteLocations: [LocationModel] = []
    @Published var onMapLocations: [LocationModel] = []
    @Published var nearbyLocations: [LocationModel] = []
    @Published var hauntedHotels: [LocationModel] = []
    @Published var trendingLocations: [LocationModel] = []
    @Published var activeTripLocations: [Destination] = [
        Destination(id: "12", lat: 12, lon: 12, name: "Bannack"),
        Destination(id: "11", lat: 11, lon: 11, name: "Sacajawea Hotel"),
        Destination(id: "10", lat: 10, lon: 10, name: "Stanley Hotel")
    ]
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
