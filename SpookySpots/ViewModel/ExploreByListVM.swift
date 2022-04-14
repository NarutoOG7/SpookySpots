//
//  ExploreByListVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import MapKit

class ExploreByListVM: ObservableObject {
    static let instance = ExploreByListVM()
    @Published var isShowingMap = false
    
    @ObservedObject var geoFireManager = GeoFireManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    @Published var searchRegion = MapDetails.defaultRegion
    
    func supplyLocationLists() {
        geoFireManager.getNearbyLocations(
            region: locServiceIsEnabled() ? self.searchRegion : MapDetails.defaultRegion,
            radius: 700)
        
        FirebaseManager.instance.getTrendingLocations()
        
//        FirebaseManager.instance.getTrendingLocations { trendingLocation in
//            if !self.locationStore.trendingLocations.contains(where: { $0.id == trendingLocation.id }) {
//                self.locationStore.trendingLocations.append(trendingLocation)
//            }
//        }
    }
    
    func locServiceIsEnabled() -> Bool {
        userLocManager.locationServEnabled
    }
    
    func setCurrentLocRegion(_ currentLoc: CLLocation) {
        self.searchRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MapDetails.defaultSpan)
    }
}
