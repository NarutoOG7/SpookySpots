//
//  ExploreByListVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import MapKit

class ExploreViewModel: ObservableObject {
    
    static let instance = ExploreViewModel()
    
    @Published var isShowingMap = false
    @Published var showingLocationList = false
    @Published var showingSearchLocations = false
    
    @Published var searchedLocations: [LocationModel] = []
    @Published var searchRegion = MapDetails.defaultRegion
    @Published var highlightedAnnotation: LocationAnnotationModel?
    
    @Published var displayedLocation: LocationModel? {
        didSet {
            if let displayedLocation = displayedLocation {
                setRegion(location: displayedLocation)
                
                if let highlightedLocation = geoFireManager.gfOnMapLocations.first(where: { $0.id == "\(displayedLocation.location.id)"}) {
                    self.highlightedAnnotation = highlightedLocation
                    
                }
            }
        }
    }
    
    @Published var searchText = "" {
        willSet {
            self.searchedLocations = []
            self.searchLogic(text: newValue) { locations in
                if let locations = locations {
                    self.searchedLocations = locations
                }
            }
        }
    }

    @ObservedObject var geoFireManager = GeoFireManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func supplyLocationLists() {
        
        geoFireManager.getNearbyLocations(
            region: locServiceIsEnabled() ? self.searchRegion : MapDetails.defaultRegion,
            radius: 700)
        let firebaseManager = FirebaseManager.instance
        
        firebaseManager.getTrendingLocations { error in
            self.errorManager.message = error
            self.errorManager.shouldDisplay = true
        }
        firebaseManager.getFeaturedLocations { error in
            self.errorManager.message = error
            self.errorManager.shouldDisplay = true
        }
        firebaseManager.getHauntedHotels()
        
        firebaseManager.getAllReviews { review in
            self.locationStore.reviewBucket.append(review)
        }

    }
    
    func locServiceIsEnabled() -> Bool {
        userLocManager.locationServicesEnabled
    }
    
    func setCurrentLocRegion(_ currentLoc: CLLocation) {
        self.searchRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MapDetails.defaultSpan)
    }
    
    func setRegion(location: LocationModel) {
        
        FirebaseManager.instance.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
            
            let region = MKCoordinateRegion(
                center: cloc.coordinate,
                span: MapDetails.defaultSpan)
            
            withAnimation(.easeInOut) {
                self.searchRegion = region
            }
        }
    }
    
    func setRegion(destination: Destination) {
        
        let center = CLLocationCoordinate2D(latitude: destination.lat,
                                            longitude: destination.lon)
        let region = MKCoordinateRegion(
            center: center,
            span: MapDetails.defaultSpan)
        
        withAnimation(.easeInOut) {
            self.searchRegion = region
        }
    }
    
    func showLocation(_ loc: LocationModel) {
        
        withAnimation(.easeInOut) {
            displayedLocation = loc
        }
        
        if let anno = geoFireManager.gfOnMapLocations.first(where: { $0.id == "\(loc.location.id)" }) {
            highlightedAnnotation = anno
        }
    }
    
    func showLocationOnSwipe(direction: SwipeDirection) {
        
        guard let currentIndex = locationStore.onMapLocations.firstIndex(where: { $0 == displayedLocation }) else {
            print("Could not find current index in onMapLocations array. Should Never Happen!")
            return
        }
        let nextIndex = (direction == .backward) ? currentIndex - 1 : currentIndex + 1
        
        guard locationStore.onMapLocations.indices.contains(nextIndex) else {
            /// next index not valid
            /// restart at zero
            guard let first = locationStore.onMapLocations.first else { return }
            showLocation(first)
            return
        }
        
        let nextLocation = locationStore.onMapLocations[nextIndex]
        showLocation(nextLocation)
    }
    
    //MARK: - Greeting Logic
    
    func greetingLogic() -> String {
        
      let hour = Calendar.current.component(.hour, from: Date())
      
      let morning = 0
      let noon = 12
      let sunset = 18
      let midnight = 24
      
      var greetingText = "Hello"
        
      switch hour {
          
      case morning..<noon:
          greetingText = "Good Morning"
          
      case noon..<sunset:
          greetingText = "Good Afternoon"
          
      case sunset..<midnight:
          greetingText = "Good Evening"

      default:
          _ = "Hello"
      }
      
      return greetingText
    }
    
    
    //MARK: - Search Logic
    
    func searchLogic(text: String, withCompletion completion: @escaping([LocationModel]?) -> () = {_ in}) {
        if text != "" {
            let filtered = locationStore.hauntedHotels.filter({ $0.location.name.localizedCaseInsensitiveContains(text) })
            completion(filtered)
        } else {
            completion(nil)
        }
    }
    
    //MARK: - Swipe Locations List
    
    enum SwipeDirection {
        case backward, forward
    }
}
