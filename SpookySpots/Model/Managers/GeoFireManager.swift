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
    @Published var gfOnMapLocations: [LocationAnnotationModel] = [] {
        willSet {
            if let last = newValue.last {
                self.getLocationDataFromKey(key: last.id) { location in
                    self.locationStore.onMapLocations.append(location)
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
    
    func searchForLocations(region: MKCoordinateRegion) {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        let regionCenter = region.center
        let radius = region.distanceMax()
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        circleQuery.observe(.keyEntered, with: { key, loc in
            let locAnnoModel = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key)
            if !self.gfOnMapLocations.contains(locAnnoModel) {
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
    
    
    
    func removeGeoFireLocations() {
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        for i in 1...108 {
            print(i)
            geoLocRef.removeKey("\(i)")
        }
    }
    
    
    
    
    
    func getLocationDataFromKey(key: String, withCompletion completion: @escaping ((_ location: Location) -> (Void))) {
        let ref = Database.database().reference().child("Haunted Hotels")
        ref.observe(.value) { snapshot in
            
            for location in snapshot.children.allObjects as! [DataSnapshot] {
                let data = location.value as? [String : AnyObject]
                let id = data?["id"] as? Int ?? Int.random(in: 200...300)
                
                if "\(id)" == key {
                    
                    let name = data?["name"] as? String ?? ""
                    let street = data?["street"] as? String ?? ""
                    let city = data?["city"] as? String ?? ""
                    let state = data?["state"] as? String ?? ""
                    let country = data?["country"] as? String ?? ""
                    let zipCode = data?["zipCode"] as? String ?? ""
                    let description = data?["description"] as? String ?? ""
                    let moreInfoLink = data?["moreInfoLink"] as? String ?? ""
                    let avgRating = data?["avgRating"] as? Double ?? 0
                    let lastReview = data?["lastReview"] as? String ?? ""
                    let lastRating = data?["lastRating"] as? Int ?? 0
                    let lastReviewTitle = data?["lastReviewTitle"] as? String ?? ""
                    let lastReviewUser = data?["lastReviewUser"] as? String ?? ""
                    let imageName = data?["imageName"] as? String ?? ""
                    let hasTours = data?["offersGhostTours"] as? Bool ?? false
                    let hotelKey = data?["hotelKey"] as? String ?? ""
                    
                    //                    let lat = data?["l/0"] as? Double ?? 0
                    //                    let lon = data?["l/1"] as? Double ?? 0
                    
                    let addressString = street + ", \(city), \(state) "
                    
                    self.firebaseManager.getCoordinatesFrom(address: addressString) { coordinates in
                        let lat = coordinates.latitude
                        let lon = coordinates.longitude
                        let clloc = CLLocation(latitude: lat, longitude: lon)
                        
                        HotelPriceManager.instance.getPriceOfHotel(key: hotelKey) { hotelPriceModel in
                            
                            let price = hotelPriceModel.lowestPrice
                            
                            self.firebaseManager.getImageFromURLString(imageName) { image in
                                let local = Location(id: id, name: name, address: Address(address: street, city: city, state: state, zipCode: zipCode, country: country), description: description, moreInfoLink: moreInfoLink, review: Review(avgRating: avgRating, lastRating: lastRating, lastReview: lastReview, lastReviewTitle: lastReviewTitle, user: lastReviewUser), locationType: "Haunted Hotel", cLLocation: clloc, tours: hasTours, imageName: imageName, baseImage: image, distanceToUser: nil, price: price)
                                completion(local)
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    
    
    //MARK: - Initialize GeoLocations
    /// This is going to turn the database locations into geo fire fetchable locations... only need to call when new location is added to database
    func listenAndAddToGeoFire() {
        /// creates geofire locations that can be fetched by region
        locationRef.observe(.childAdded) { snapshot in
            let location = Location(snapshot: snapshot)
            self.getLocationDataFromKey(key: "\(location.id)") { location in
                print(location)
                self.createSpookyLocation(forLocation: location)
            }
        }
    }
    
    func createSpookyLocation(forLocation location: Location) {
        if let loc = location.cLLocation {
            let geoLocRef = GeoFire(firebaseRef: locationRef)
            geoLocRef.setLocation(loc, forKey: "\(location.id)")
        }
    }
}
