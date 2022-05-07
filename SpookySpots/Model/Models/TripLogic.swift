//
//  TripLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//

import SwiftUI

class TripLogic: ObservableObject {
    static let instance = TripLogic()
    
    private var trips: [TripTwo] = []
    private var currentTrip: TripTwo?
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    init() {
        // load from firebase
        if userStore.isSignedIn {
            firebaseManager.getTripLocationsForUser { trip in
                self.trips.append(trip)
                
                self.currentTrip = trips.last
            }
        }
    }
    
    
}
