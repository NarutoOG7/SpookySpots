//
//  GeoFireManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import SwiftUI
import GeoFire


class GeoFireManager: ObservableObject {
    static let instance = GeoFireManager()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    @ObservedObject var locationStore = LocationStore.instance
    

    lazy var locationRef = Database.database().reference().child("Haunted Hotels")
    @Published var gfNearbyLocations: [LocationAnnotationModel] = []
    @Published var gfOnMapLocations: [LocationAnnotationModel] = []
    
    var locationHandle: DatabaseHandle?
    
    /// for display on the EXPLORE by LIST page.
    func getNearbyLocations(region: MKCoordinateRegion, radius: Double) {
        
        if UserStore.instance.currentLocation != nil {
        
            let geoLocRef = GeoFire(firebaseRef: locationRef)
            let regionCenter = region.center
            let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
            let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
            circleQuery.observe(.keyEntered, with: { key, loc in
                
                self.firebaseManager.getSelectHotel(key) { locModel in
                    let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
                    
                    if !self.gfNearbyLocations.contains(where: { $0.id == key }) {
                        self.gfNearbyLocations.append(anno)
                        
                        if !self.locationStore.nearbyLocations.contains(where: { "\($0.location.id)" == key }) {
                            self.locationStore.nearbyLocations.append(locModel)
                        }
                    }
                }
            })
        }
    }
    
    
    /// used by "search area" button..  want to get rid of.
    func searchForLocations(region: MKCoordinateRegion) {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = region.center
        let radius = region.distanceMax() / 2
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            
            self.firebaseManager.getSelectHotel(key) { locModel in
                
                let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
                
                if !self.gfOnMapLocations.contains(where: { $0.id == key }) {
                    self.gfOnMapLocations.append(anno)
                    
                    if !self.locationStore.onMapLocations.contains(where: { "\($0.location.id)" == key }) {
                        self.locationStore.onMapLocations.append(locModel)
                    }
                }
            }
        })
    }
    
    
    //MARK: - Location Listener
    /// need to try this out to get rid of the "search area" button.. haha lame ass button gtfo....
    func startLocationListener() {
        let region = exploreByMapVM.region
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = region.center
        let radius = region.distanceMax() / 2
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            
            self.firebaseManager.getSelectHotel(key) { locModel in
                
                let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
                
                if !self.gfOnMapLocations.contains(where: { $0.id == key }) {
                    self.gfOnMapLocations.append(anno)
                    
                    if !self.locationStore.onMapLocations.contains(where: { "\($0.location.id)" == key }) {
                        self.locationStore.onMapLocations.append(locModel)
                    }
                }
            }
        })
    }
    
    func endLocationListener() {
        if let locationHandle = locationHandle{
            locationRef.removeObserver(withHandle: locationHandle)
            print(gfOnMapLocations.count)
        }
    }
         
    
    //MARK: - GeoFire wire into RTD
    
    ///  This should only be accessible by  admin
    func createSpookySpotForLocation(_ location: LocationModel, withCompletion completion: @escaping(Bool) -> Void) {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
            print(location.id)
            geoLocRef.setLocation(cloc, forKey: "\(location.location.id)") { error in
                    if let error = error {
                        print(error)
                        completion(false)
                    } else {
                        print("Success: \(location.id)")
                        
                    }
                    completion(true)
                }
            }
        }
}
