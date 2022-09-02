//
//  UserStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation
import FirebaseAuth
import MapKit


class UserStore: ObservableObject {
    static let instance = UserStore()
        
    @Published var isSignedIn = UserDefaults.standard.bool(forKey: "signedIn")
    
//    @Published var isSignedIn = false
    @Published var isGuest = false
    @Published var user = User()
    @Published var currentLocation: CLLocation? {
        willSet {
            if let newValue = newValue {
            let region = MKCoordinateRegion(center: newValue.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                ExploreViewModel.instance.searchRegion = region
//                RegionWrapper.instance.region = region
        }
        }
    }
    @Published var trip: Trip?
    @Published var selectedLocationDistanceToUser: Double = 0
    
    @Published var reviews: [ReviewModel] = []
    

}
