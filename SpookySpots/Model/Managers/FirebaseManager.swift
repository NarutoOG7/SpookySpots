//
//  FirebaseManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
//import Firebase
import FirebaseFirestore
//import FirebaseDatabase
import CoreLocation
import GeoFire
import Firebase
import MapKit


class FirebaseManager: ObservableObject {
    let constantToNeverTouch = FirebaseApp.configure()
    static let instance = FirebaseManager()
    
    //    @ObservedObject var userLocManager = UserLocationManager.instance
    //    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userStore = UserStore.instance
    
    @Published var favoriteLocations: [FavoriteLocation] = []
    
    var db: Firestore?
    
    init() {
        db = Firestore.firestore()
    }
    
    func getLocationImages(locID: String, withCompletion completion: @escaping(_ fsImage: FSImage) -> Void) {
        
        guard let db = db else { return }

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
        
        guard let db = db else { return }

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
        
        guard let db = db else { return }

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
        
        guard let db = db else { return }

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
        
        guard let db = db else { return }

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
                
        guard let db = db else { return }

        db.collection("Favorites").document(favLoc.id)
            .delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
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


//MARK: Consecutive Sequence /// for allowing points to be able to be used in for loop
public struct ConsecutiveSequence<T: IteratorProtocol>: IteratorProtocol, Sequence {
    private var base: T
    private var index: Int
    private var previous: T.Element?
    
    init(_ base: T) {
        self.base = base
        self.index = 0
    }
    
    public typealias Element = (T.Element, T.Element)
    
    public mutating func next() -> Element? {
        guard let first = previous ?? base.next(), let second = base.next() else {
            return nil
        }
        
        previous = second
        
        return (first, second)
    }
}

extension Sequence {
    public func makeConsecutiveIterator() -> ConsecutiveSequence<Self.Iterator> {
        return ConsecutiveSequence(self.makeIterator())
    }
}


//MARK: - Decode Data

struct Dict {
    let key: String
    let value: Any
}
func decodeDataToObject<Dict: Codable>(data : Data?) -> Dict? {
    
    if let dt = data {
        do {
            
            return try JSONDecoder().decode(Dict.self, from: dt)
            
        }  catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
    
    return nil
}
