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

    let locationStore = LocationStore.instance
    //    @Published var images: [Location.Images] = []
    //
    //    init() {
    ////        getImages()
    //    }

    
    func getHauntedHotels(withCompletion completion: @escaping ((_ location: Location) -> Void)) {
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
                    let hasTours = data?["offersGhostTours"] as? Bool ?? false
                    let hotelKey = data?["hotelKey"] as? String ?? ""
                    let lat = data?["l/0"] as? Double ?? 0
                    let lon = data?["l/1"] as? Double ?? 0

                    let clloc = CLLocation(latitude: lat, longitude: lon)

                    self.getImageFromURLString(imageName) { image in

//                        HotelPriceManager.instance.getPriceOfHotel(key: hotelKey) { hotelPriceModel in
//                            let price = hotelPriceModel?.lowestPrice


                            let local = Location(id: id, name: name, address: Address(address: street, city: city, state: state, zipCode: zipCode, country: country), description: description, moreInfoLink: moreInfoLink, review: Review(avgRating: avgRating, lastRating: lastRating, lastReview: lastReview, lastReviewTitle: lastReviewTitle, user: lastReviewUser), locationType: "Haunted Hotel", cLLocation: clloc, tours: hasTours, imageName: imageName, baseImage: image, distanceToUser: nil, price: 0)

                        completion(local)
                        self.locationStore.hauntedHotels.append(local)

//                    }
                }
                    //                    }




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
                    
                    _ = Location.Images(id: id, imageURL: imageURL, locationID: imageLocationID)
                    //                    self.images.append(img)
                }
            }
        }
    }
    
    //    func getImageFromLocationID(id: Int, withCompletion completion: @escaping ((_ image: Location.Images) -> (Void))) {
    //        for image in self.images {
    //            if image.locationID == id {
    //                completion(image)
    //            }
    //        }
    //
    //    }
    //
    func getImageFromURLString(_ urlString: String, withCompletion completion: @escaping ((_ image: Image) -> (Void))) {
            var imageToReturn = Image("bannack")
            let storageRef = Storage.storage().reference().child(urlString)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let data = data else { return }
                if let image = UIImage(data: data) {
                    imageToReturn = Image(uiImage: image)
                    completion(imageToReturn)
                }
            }
        
    }
    
    
    
    //MARK: - Queries
    enum Queries: String, CaseIterable {
        case hauntedHotels = "Haunted Hotels"
        case ghostTowns = "Ghost Towns"
        
    }
    
    //MARK: - Coordinates & Address
    func getCoordinatesFrom(address: String, withCompletion completion: @escaping ((_ coordinates: CLLocationCoordinate2D) -> (Void))) {
        
        let addressString = address
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
            else {
                // handle no location found
                print("error on forward geocoding.. getting coordinates from location address: \(addressString)")
                return
            }
            //            print("successful geocode with addrress: \(addressString)")
            completion(loc.coordinate)
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
