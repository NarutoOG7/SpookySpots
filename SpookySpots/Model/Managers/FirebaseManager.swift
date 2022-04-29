//
//  FirebaseManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
//import Firebase
//import FirebaseFirestore
//import FirebaseDatabase
import CoreLocation
import GeoFire
import Firebase


class FirebaseManager: ObservableObject {
    static let instance = FirebaseManager()
    
    //    @ObservedObject var userLocManager = UserLocationManager.instance
    //    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    
    @ObservedObject var locationStore = LocationStore.instance
    
    func getLocationImages(locID: String, withCompletion completion: @escaping(_ fsImage: FSImage) -> Void) {
        
        let db = Firestore.firestore()
        
        db.collection("Images").whereField("locID", isEqualTo: locID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshot = querySnapshot {
                    for document in snapshot.documents {
                        let dict = document.data()
                        let image = FSImage(dict: dict)
                        completion(image)
                    }
                }
            }
        }
    }
    
    func getHauntedHotels() {
        let ref = Database.database().reference().child("Haunted Hotels")
        ref.observe(.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.locationStore.hauntedHotels.removeAll()
                
                if let objects = snapshot.children.allObjects as? [DataSnapshot] {
                    for object in objects {
                        if let data = object.value as? [String : AnyObject] {
                            let locData = LocationData(data: data)
                            var imageURLs: [URL] = []
                            self.getLocationImages(locID: "\(locData.id)") { fsImage in
                                if let url = URL(string: "\(fsImage.imageURL)") {
                                    imageURLs.append(url)
                                }
                            }
                            let locModel = LocationModel(location: locData, imageURLs: imageURLs, reviews: [])
                            self.locationStore.hauntedHotels.append(locModel)
                        }
                    }
                }
            }
        }
    }
    
    func setFavoriteLocation(location: LocationModel) {
        let db = Firestore.firestore()
        
        db.document(UUID().uuidString).setData( [
            "locationID" : "\(location.location.id)",
            "userID" : "\(UserStore.instance.user.id)"
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getImageURLFromFBPath(_ urlString: String, withCompletion completion: @escaping ((_ url: URL) -> (Void))) {
        
        let storageRef = Storage.storage().reference().child(urlString)
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let url = url else { return }
            completion(url)
        }
    }
        
    func getTrendingLocations() {
        
        let db = Firestore.firestore()
        
        db.collection("Trending").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshot = querySnapshot {
                    for document in snapshot.documents {
                        let dict = document.data()
                        
                        if let location = self.locationStore.hauntedHotels.first(where: { $0.location.id == dict["id"] as? Int ?? 0}) {
                            if !self.locationStore.trendingLocations.contains(location) {
                                self.locationStore.trendingLocations.append(location)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getFavoritesForUser() {
        let db = Firestore.firestore()
        
        db.collection("Favorites")
        
            .whereField("id", isEqualTo: UserStore.instance.user.id)
        
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("error getting favorites: \(error)")
                } else {
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let dict = document.data()
                            
                            if let location = self.locationStore.hauntedHotels.first(where: { $0.location.id == dict["id"] as? Int ?? 0 }) {
                                self.locationStore.favoriteLocations.append(location)
                            }
                        }
                    }
                }
            }
    }
    
    //MARK: - Queries
    enum Queries: String, CaseIterable {
        case hauntedHotels = "Haunted Hotels"
        case ghostTowns = "Ghost Towns"
        
    }
    
    //MARK: - Coordinates & Address
    
    func getCoordinatesFromAddress(address: String, withCompletion completion: @escaping (CLLocation) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
            else {
                // handle no location found
                print("error on forward geocoding.. getting coordinates from location address: \(address)")
                return
            }
            //            print("successful geocode with addrress: \(addressString)")
            print(loc)
            completion(loc)
        }
    }
    
    
    func getAddressFrom(coordinates: CLLocationCoordinate2D, withCompletion completion: @escaping ((_ location: Address) -> (Void))) {
        let location  = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first
            else {
                // Handle error
                return
            }
            if let buildingNumber = location.subThoroughfare,
               let street = location.thoroughfare,
               let city = location.locality,
               let state = location.administrativeArea,
               let zip = location.postalCode,
               let country = location.country {
                
                let address = Address(
                    address: "\(buildingNumber) \(street)",
                    city: city,
                    state: state,
                    zipCode: zip,
                    country: country)
                completion(address)
            }
        }
    }
}


//MARK: - Image Load From URL
extension Image {
    func data(url: URL?) -> Self {
        if let url = url,
           let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self
            .resizable()
    }
}
