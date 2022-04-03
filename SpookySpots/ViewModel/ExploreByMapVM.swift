//
//  ExploreByMapVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit

class ExploreByMapVM: ObservableObject {
    static let instance = ExploreByMapVM()
    
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userStore = UserStore.instance
    
    var selectedLocationDistance: Double = 0
    
    @Published var locationShownOnList: Location?
    @Published var region = MKCoordinateRegion(
        center: MapDetails.startingLocation.coordinate,
        span: MapDetails.defaultSpan)
    
    @Published var showingLocationList = false
//    @Published var region = MKCoordinateRegion(
//        center: MapDetails.startingLocation.coordinate,
//        span: MapDetails.defaultSpan) {
//            willSet {
//                let center = newValue.center
//                let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)
//                GeoFireManager.instance.showSpotsOnMap(location: loc) { location in
//                    self.locationStore.onMapLocations.append(location)
//                }
//            }
//        }
    
}
