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
    @Published var gfNearbyLocations: [LocationAnnotationModel] = [] {
        willSet {
            if let last = newValue.last {
                self.getLocationDataFromKey(key: last.id) { location in
                    self.locationStore.nearbyLocations.append(location)
                }
            }
        }
    }
    @Published var gfOnMapLocations: [LocationAnnotationModel] = [] {
        willSet {
            if let last = newValue.last {
                self.getLocationDataFromKey(key: last.id) { location in
                    if self.locationStore.onMapLocations.contains(where: { "\($0.id)" == last.id }) {
                        self.locationStore.onMapLocations.append(location)
                    }
                }
            }
        }
    }
    //    {
    //        willSet {
    //            if let nextAdded = newValue.last {
    //                self.getLocationDataFromKey(key: nextAdded.id) { location in
    //                    if !self.locationStore.onMapLocations.contains(location) {
    //                        self.locationStore.onMapLocations.append(location)
    //                    }
    //                }
    //            }
    //        }
    //    }
    var locationHandle: DatabaseHandle?
    
    //    init() {
    //        geoFireRef = Database.database().reference()
    //        geoFire = GeoFire(firebaseRef: geoFireRef)
    //
    //    }
    //
    //    func showSpotsOnMap(location: CLLocation, withCompletion completion: @escaping ((_ location: Location) -> (Void))) {
    //        let regionCenter = exploreByMapVM.region.center
    //        let location = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
    //        if let geoFire = geoFire {
    //            let circleQuery = geoFire.query(at: location, withRadius: 1000)
    //
    //            circleQuery.observe(.keyEntered, with: { key, loc in
    //                self.getLocationDataFromKey(key: key) { local in
    //                    let locAnnotationModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
    //                    print(local.name)
    //                    self.gfOnMapLocations.append(locAnnotationModel)
    //                    completion(local)
    //                }
    //            })
    //        }
    //    }
    
    func getNearbyLocations(region: MKCoordinateRegion, radius: Double) {
        
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        let regionCenter = region.center
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            let locAnnoModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
            if !self.gfNearbyLocations.contains(where: { $0.id == key }) {
                self.gfNearbyLocations.append(locAnnoModel)
            }
        })
    }
    
    func searchForLocations(region: MKCoordinateRegion) {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = region.center
        let radius = region.distanceMax()
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            let locAnnoModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
            if !self.gfOnMapLocations.contains(where: { $0.id == key }) {
                self.gfOnMapLocations.append(locAnnoModel)
            }
        })
    }
    
    func startLocationListener() {
        print(gfOnMapLocations.count)
        //        if let geoFire = geoFire {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = exploreByMapVM.region.center
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: 200)
        locationHandle = circleQuery.observe(.keyEntered, with: { key, loc in
            let locAnnotationModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
            if !self.gfOnMapLocations.contains(where: { $0.id == locAnnotationModel.id}) {
                self.gfOnMapLocations.append(locAnnotationModel)
            }
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
                        
                        var location = Location(dictionary: data)
                    
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
}
