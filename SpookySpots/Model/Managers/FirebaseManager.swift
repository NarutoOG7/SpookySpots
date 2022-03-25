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
    
    enum Queries: String, CaseIterable {
        case hauntedHotels = "Haunted Hotels"
        case ghostTowns = "Ghost Towns"
        
    }
    
    @ObservedObject var userLocManager = UserLocationManager.instance
    
    var geoFireRef: DatabaseReference!
    var geoFire: GeoFire!
//    let db = Firestore.firestore()
    let locationStore = LocationStore.instance
    @Published var images: [Location.Images] = []
    init() {
        geoFireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        getHauntedHotels()
//        setCoordinates()
        getImages()
    }
    
    
    func getHauntedHotels() {
        let ref = Database.database().reference().child("Haunted Hotels")
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                
                self.locationStore.hauntedHotels.removeAll()
                
                
                for location in snapshot.children.allObjects as! [DataSnapshot] {
                    let data = location.value as? [String : AnyObject]
                    let id = data?["id"] as? Int ?? Int.random(in: 200...300)
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

                    let local = Location(id: id, name: name, address: Address(address: street, city: city, state: state, zipCode: zipCode, country: country), description: description, moreInfoLink: moreInfoLink, review: Location.Review(avgRating: avgRating, lastRating: lastRating, lastReview: lastReview, lastReviewTitle: lastReviewTitle, user: lastReviewUser), locationType: "Haunted Hotel", cLLocation: nil, tours: nil, imageName: imageName, baseImage: nil, distanceToUser: nil)
//                    let local = LocationModel(id: id, name: name, address: Address(address: street, city: city, state: state, zipCode: zipCode, country: country), description: description, moreInfoLink: moreInfoLink, review: Location.Review(avgRating: avgRating, lastRating: lastRating, lastReview: lastReview, user: lastReviewUser), locationType: "Haunted Hotel", coordinates: nil, imageName: imageName, baseImage: nil, distanceToUser: nil)
//                    let local = LocationModel(id: id, name: name, address: Address(address: street, city: city, state: state, zipCode: zipCode, country: country), description: description, moreInfoLink: moreInfoLink, review: Location.Review(avgRating: avgRating, lastRating: lastRating, lastReview: lastReview, user: lastReviewUser), locationType: "Haunted Hotel", imageName: imageName)
                    self.locationStore.hauntedHotels.append(local)
                }
            }
        }
        
    }
    func getImages() {
        
        let ref = Database.database().reference().child("Images")
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for image in snapshot.children.allObjects as! [DataSnapshot] {
                    let data = image.value as? NSDictionary
                    let imageLocationID = data?["locationID"] as? Int ?? Int.random(in: 1000...2000)
                    let imageURL = data?["imageURL"] as? String ?? ""
                    let id = data?["id"] as? Int ?? Int.random(in: 3000...4000)
                    
                    let img = Location.Images(id: id, imageURL: imageURL, locationID: imageLocationID)
                    self.images.append(img)
                }
            }
        }
    }
    
    func getImageFromLocationID(id: Int, withCompletion completion: @escaping ((_ image: Location.Images) -> (Void))) {
        for image in self.images {
            if image.locationID == id {
                completion(image)
            }
        }
        
    }
    
    func getImageFromURLString(_ urlString: String) -> Image {
        var imageToReturn = Image("blank")
        let storageRef = Storage.storage().reference().child(urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let data = data else { return }
            if let image = UIImage(data: data) {
               imageToReturn = Image(uiImage: image)
            }
        }
        return imageToReturn
    }
    
    //MARK: - GeoFire
    
    func createSpookyLocation(forLocation location: Location) {
        if let loc = location.cLLocation {
            geoFire.setLocation(loc, forKey: "\(location.id)")
        }
    }
    
    func getLocationsFromSpecificRadius(withCompletion completion: @escaping ((_ location: String) -> (Void))) {

//        var centerCoordinates = userLocManager.region.center
//        var center = CLLocation(latitude: centerCoordinates.latitude, longitude: centerCoordinates.longitude)
//        var radius = userLocManager.region.span

        // Query location by region
        let region = userLocManager.region
        let regionQuery = geoFire.query(with: region)

        regionQuery.observe(.keyEntered, with: { (key : String, location: CLLocation) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            

            completion(key)
        })
        
        
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
