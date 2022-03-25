//
//  UserStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation
import CoreLocation


class UserStore: ObservableObject {
    static let instance = UserStore()
    
    @Published var user = User()
    @Published var currentLocation: CLLocation?
    @Published var favoriteLocations: [Location] = []
    @Published var trip: Trip?
    @Published var selectedLocationDistanceToUser: Double = 0
}
