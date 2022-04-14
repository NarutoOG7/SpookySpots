//
//  UserStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation
import CoreLocation
import MapKit


class UserStore: ObservableObject {
    static let instance = UserStore()
    
    @Published var isSignedIn = false
    @Published var user = User()
    @Published var currentLocation: CLLocation? {
        willSet {
            if let newValue = newValue {
            let region = MKCoordinateRegion(center: newValue.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            ExploreByMapVM.instance.region = region
//                RegionWrapper.instance.region = region
        }
        }
    }
    @Published var favoriteLocations: [Location] = []
    @Published var trip: Trip?
    @Published var selectedLocationDistanceToUser: Double = 0
}
