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
    
    //        var geoFireRef: DatabaseReference!
    //    var geoFire: GeoFire?
    //    lazy var locationRef = GeoFire(firebaseRef: Database.database().reference().child("Haunted Hotels"))
    lazy var locationRef = Database.database().reference().child("Haunted Hotels")
    @Published var gfNearbyLocations: [LocationAnnotationModel] = []
    @Published var gfOnMapLocations: [LocationAnnotationModel] = []
    
    var locationHandle: DatabaseHandle?
    
    //    init() {
    //        geoFireRef = Database.database().reference()
    //        geoFire = GeoFire(firebaseRef: geoFireRef)
    //
    //    }
   
    
    func getNearbyLocations(region: MKCoordinateRegion, radius: Double) {
        
        if UserStore.instance.currentLocation != nil {
        
            let geoLocRef = GeoFire(firebaseRef: locationRef)
            let regionCenter = region.center
            let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
            let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
            circleQuery.observe(.keyEntered, with: { key, loc in
                if let location = self.locationStore.hauntedHotels.first(where: { "\($0.id)" == key }) {
                    print(location)
                    let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
                    
                    if !self.gfNearbyLocations.contains(where: { $0.id == key }) {
                        self.gfNearbyLocations.append(anno)
                        
                        if !self.locationStore.nearbyLocations.contains(where: { "\($0.id)" == key }) {
                            self.locationStore.nearbyLocations.append(location)
                        }
                    }
                }
            })
        }
    }
    
    func searchForLocations(region: MKCoordinateRegion) {
        if gfOnMapLocations.count != locationStore.hauntedHotels.count {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = region.center
        let radius = region.distanceMax() / 2
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            if let location = self.locationStore.hauntedHotels.first(where: { "\($0.id)" == key }) {
                print(location)
                let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
                
                if !self.gfOnMapLocations.contains(where: { $0.id == key }) {
                    self.gfOnMapLocations.append(anno)
                    
                    if self.locationStore.onMapLocations.contains(where: { "\($0.id)" == key }) {
                        self.locationStore.onMapLocations.append(location)
                    }
                }
            }
        })
        }
    }
    
    func startLocationListener() {
        print(gfOnMapLocations.count)
        //        if let geoFire = geoFire {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = exploreByMapVM.region.center
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: 200)
        locationHandle = circleQuery.observe(.keyEntered, with: { key, loc in
            
            if let loc = self.locationStore.hauntedHotels.first(where: { $0.geoKey == key }) {
                print(loc)
            }
            
//            let locAnnotationModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
//            if !self.gfOnMapLocations.contains(where: { $0.id == locAnnotationModel.id}) {
//                self.gfOnMapLocations.append(locAnnotationModel)
//            }
        })
        //        }
    }
    
    func endLocationListener() {
        if let locationHandle = locationHandle{
            locationRef.removeObserver(withHandle: locationHandle)
            print(gfOnMapLocations.count)
        }
    }
    
    func getLocationDataFromKey(key: String, withCompletion completion: @escaping ((_ location: Location) -> (Void))) {
        
        let ref = Database.database().reference().child("Haunted Hotels")
        print(key)
        ref.child(key).getData { error, snapshot in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
//            for object in snapshot.children.allObjects as! [DataSnapshot] {
                
            if let data = snapshot.value as? [String : AnyObject] {
                        
                        var location = Location(data: data)
                    
                    print(location.id)
                        
//                        if let hotelPriceKey = location.hotelKey {
                            
//                            HotelPriceManager.instance.getPriceOfHotel(key: hotelPriceKey) { hotelPriceModel in
//
//                                let price = hotelPriceModel.lowestPrice
//
//                                location.addPrice(price)
//                                //
                                print(location)
//                                self.firebaseManager.getImageFromURLString(imageName) { image in
                                completion(location)
                                //                            }
//                            }
//
//                        }
//                    }
                }
            }
//        })
    }
    
//    func createSpookySpotGeoRefForAllLocations() {
//        let geoLocRef = GeoFire(firebaseRef: locationRef)
//        print(locationStore.hauntedHotels.count)
//        for location in locationStore.hauntedHotels {
//            print(location.address?.geoCodeAddress() ?? "")
//            firebaseManager.getCoordinatesFromAddress(address: location.address?.geoCodeAddress() ?? "") { cloc in
//                geoLocRef.setLocation(cloc, forKey: "\(location.id)") { error in
//                    if let error = error {
//                        print(error)
//                    }
//                    print("Success: \(location.id)")
//                }
//            }
//        }
//    }
    
    func createSpookySpotForLocation(_ location: Location, withCompletion completion: @escaping(Bool) -> Void) {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        firebaseManager.getCoordinatesFromAddress(address: location.address?.geoCodeAddress() ?? "") { cloc in
            print(location.id)
                geoLocRef.setLocation(cloc, forKey: "\(location.id)") { error in
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
