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
        Location(id: 1231, name: "Armstrong Hotel", cLLocation: CLLocation(latitude: 40.58451, longitude: -105.07762), baseImage: Image("bannack")),
        Location(id: 1232, name: "Stanley Hotel", cLLocation: CLLocation(latitude: 40.58451, longitude: -105.07762), baseImage: Image("bannack")),
        Location(id: 1233, name: "Grand Union Hotel", cLLocation: CLLocation(latitude: 40.58451, longitude: -105.07762), baseImage: Image("bannack")),
        Location(id: 1234, name: "Sacajawea Hotel", cLLocation: CLLocation(latitude: 40.58451, longitude: -105.07762), baseImage: Image("bannack")),
        Location(id: 1235, name: "Hotel Occidental", cLLocation: CLLocation(latitude: 40.58451, longitude: -105.07762), baseImage: Image("bannack"))
    ]
        
    @Published var srchcText = ""
    
    @Published var locations: [Location] = []
    @Published var favoriteLocations: [Location] = []
    @Published var hauntedHotels: [Location] = [] 
    @Published var onMapLocations: [Location] = [] {
        willSet {
            print(newValue.last!)
        }
    }
    @Published var nearbyLocations: [Location] = [] {
        willSet {
            print(newValue.count)
        }
    }
    @Published var everyFavoritedLocation: [FavoriteLocation] = []
    @Published var trendingLocations: [Location] = [] {
        willSet {
            print(newValue.last)
        }
    }
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
