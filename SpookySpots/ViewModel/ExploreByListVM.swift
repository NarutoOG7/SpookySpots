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
    
    @Published var showingSearchLocations = false
    @Published var searchedLocations: [LocationModel] = []
    
    @ObservedObject var geoFireManager = GeoFireManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    @Published var searchRegion = MapDetails.defaultRegion
    
    @Published var searchText = "" {
        didSet {
            searchLogic()
        }
    }
    
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
    
    //MARK: - Greeting Logic
    func greetingLogic() -> String {
      let hour = Calendar.current.component(.hour, from: Date())
      
      let NEW_DAY = 0
      let NOON = 12
      let SUNSET = 18
      let MIDNIGHT = 24
      
      var greetingText = "Hello" // Default greeting text
        
      switch hour {
          
      case NEW_DAY..<NOON:
          greetingText = "Good Morning"
          
      case NOON..<SUNSET:
          greetingText = "Good Afternoon"
          
      case SUNSET..<MIDNIGHT:
          greetingText = "Good Evening"

      default:
          _ = "Hello"
      }
      
      return greetingText
    }
    
    
    //MARK: - Search Logic
    
     func searchLogic() {
        if self.searchText != "" {
            let locations = locationStore.hauntedHotels.filter({ $0.location.name.lowercased().contains(self.searchText.lowercased()) })
            self.searchedLocations = locations
        } else {
            self.searchedLocations = []
        }
    }
}
