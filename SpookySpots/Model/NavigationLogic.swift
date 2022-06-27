//
//  NavigationLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import SwiftUI
import MapKit

class NavigationLogic: ObservableObject {
    static let instance = NavigationLogic()
    
    @Published var route: Route?
    @Published var routes: [Route] = []
    @Published var destinations: [Destination] = []
    
    @Published var mapRegion = MKCoordinateRegion()
 
    @ObservedObject var userStore = UserStore.instance
    
    func beginNavigation(trip: Trip, routes: [Route]) {
        self.routes = routes
        self.route = routes.first
        self.destinations = trip.destinations
        
//        if let currentLoc = userStore.currentLocation?.coordinate {
        self.mapRegion = MapDetails.defaultRegion
          
    }
    
}
