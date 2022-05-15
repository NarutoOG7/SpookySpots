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
    @ObservedObject var userStore = UserStore.instance
    
    @Published var favoriteLocations: [FavoriteLocation] = []
    
    func getLocationImages(locID: String, withCompletion completion: @escaping(_ fsImage: FSImage) -> Void) {
        
        let db = Firestore.firestore()
        
        db.collection("Images")
        
            .whereField("locID", isEqualTo: locID)
        
            .getDocuments() { (querySnapshot, err) in
                
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
    
    func addOrSaveTrip(_ trip: Trip) {
        let db = Firestore.firestore()
        
//        db.collection("Trips")
//            .document(trip.id)
//            .setData([
//
//            ])
    }
    
    func getSelectHotel(_ locID: String, withCompletion completion: @escaping(LocationModel) -> Void) {
        
        let ref = Database.database().reference().child("Haunted Hotels/\(locID)")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            if let data = snapshot.value as? [String : AnyObject] {
                
                let locData = LocationData(data: data)
                
                var imageURLS: [URL] = []
                self.getLocationImages(locID: "\(locData.id)") { fsImage in
                    if let url = URL(string: "\(fsImage.imageURL)") {
                        imageURLS.append(url)
                    }
                }
                                
                let locModel = LocationModel(location: locData, imageURLs: imageURLS, reviews: [])
                
                completion(locModel)
                
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
    
//    func isLocationFavorited(_ locData: LocationData, withCompletion completion: @escaping(_ result: Bool) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("Favorites")
//            .whereField("locationID", isEqualTo: locData.id)
//            .whereField("userID", isEqualTo: UserStore.instance.user.user.id)
//
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    completion(true)
//                }
//            }
//    }
    
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
                        let key = dict["id"] as? Int ?? 0
                        
                        self.getSelectHotel("\(key)") { locModel in
                            if !self.locationStore.trendingLocations.contains(locModel) {
                                self.locationStore.trendingLocations.append(locModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getFavoritesAsIDsOnly(withCompletion completion: @escaping(FavoriteLocation) -> Void) {
        let db = Firestore.firestore()
        db.collection("Favorites")
            .whereField("userID", isEqualTo: UserStore.instance.user.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    for doc in snapshot.documents {
                        let dict = doc.data()
                        let favLocation = FavoriteLocation(
                            id: dict["id"] as? String ?? "",
                            locationID: dict["locationID"] as? String ?? "",
                            userID: dict["userID"] as? String ?? "")
                        
                        completion(favLocation)
                    }
                }
            }

    }
    
    
    func getReviewsForUser(_ user: User, withCompletion completion: @escaping(_ review: ReviewModel) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Reviews")
        
            .whereField("userID", isEqualTo: user.id)
        
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting reviews: \(error.localizedDescription)")
                } else {
                    if let snapshot = querySnapshot {
                        for doc in snapshot.documents {
                            let dict = doc.data()
                            
                            let review = ReviewModel(dictionary: dict)
                            
                            completion(review)
                        }
                    }
                }
            }
    }
    
    func addLocToFavoritesBucket(_ favLoc: FavoriteLocation, withCompletion completion: ((Bool) -> ())? = nil) {
        let db = Firestore.firestore()
        
        db.collection("Favorites").document(favLoc.id).setData([
            "id" : favLoc.id,
            "locationID" : "\(favLoc.locationID)",
            "userID" : "\(favLoc.userID)"
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    func removeFavoriteFromBucket(_ favLoc: FavoriteLocation, withCompletion completion: ((Bool) -> ())? = nil) {
        
        let db = Firestore.firestore()
        
        db.collection("Favorites").document(favLoc.id)
            .delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    //MARK: - Get Trips
    
    func getTripLocationsForUser(withCompletion completion: @escaping(Trip) -> Void) {
        let db = Firestore.firestore()

        db.collection("Trips")
            .whereField("userID", isEqualTo: UserStore.instance.user.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    for doc in snapshot.documents {
                        if let dict = doc.data() as? [String:AnyObject] {
                        let trip = Trip(dict: dict)
                        completion(trip)
                        }
                    }
                }
            }
        
    }
    
    //MARK: - Search
    
    func searchForLocationInFullDatabase(text: String, withCompletion completion: @escaping(LocationModel) -> Void) {
        let ref = Database.database().reference().child("Haunted Hotels")

        ref.queryStarting(atValue: text)
        ref.queryEnding(atValue: text)
        ref.getData { error, snapshot in
            
            if let data = snapshot.value as? [String : AnyObject] {
                
                let locData = LocationData(data: data)
                
                var imageURLS: [URL] = []
                self.getLocationImages(locID: "\(locData.id)") { fsImage in
                    if let url = URL(string: "\(fsImage.imageURL)") {
                        imageURLS.append(url)
                    }
                }
                                
                let locModel = LocationModel(location: locData, imageURLs: imageURLS, reviews: [])
                
                completion(locModel)
                
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
