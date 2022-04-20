//
//  Location.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import CoreLocation
import SwiftUI
import Firebase
import Contacts

struct Location: Identifiable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    
    static let example = Location(id: 1111,
                                  name: "Bannack",
                                  address: Address(address: "721 Bannack Rd", city: "Dillon", state: "MT", zipCode: "59725", country: "USA"),
                                  description: "Bannack State Park is a National Historic Landmark and is the best preserved of all Montana ghost towns. Back in the “Old West”, during the mighty gold rush of 1862, Bannack’s population grew over 3,000. Today, no residents remain in this town.",
                                  moreInfoLink: "https://fwp.mt.gov/stateparks/bannack-state-park",
                                  review: Review(avgRating: 5, lastRating: 5, lastReview: "Must visit anytime you are in Montana!", lastReviewTitle: "Breathtaking", user: "Spencer"),
                                  locationType: "Ghost Town",
                                  cLLocation: nil,
                                  tours: true,
                                  imageName: "FairbanksBridge.jpg",
                                  baseImage: Image("bannack"),
                                  distanceToUser: nil,
                                  price: 120)
    
    var id: Int
    var name: String
    var address: Address?
    var description: String?
    var moreInfoLink: String?
    var review: Review?
    var locationType: String?
    var cLLocation: CLLocation?
    var tours: Bool?
    var hours: String?
    var likes: Int?
    var imageName: String?
    var baseImage: Image?
    var distanceToUser: Double?
    var price: Double?
    var hotelKey: String?
    var geoKey: String?
    
    init(dictionary: [String : Any]) {
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
     hotelKey = dictionary["hotelKey"] as? String ?? ""
        address?.address = dictionary["street"] as? String ?? ""
        address?.city = dictionary["city"] as? String ?? ""
        address?.state = dictionary["state"] as? String ?? ""
        address?.zipCode = dictionary["zipCode"] as? String ?? ""
        address?.country = dictionary["country"] as? String ?? ""
        description = dictionary["description"] as? String ?? ""
        moreInfoLink = dictionary["moreInfoLink"] as? String ?? ""
        tours = dictionary["tours"] as? Bool ?? false
        imageName = dictionary["imageName"] as? String ?? ""
        baseImage = dictionary["baseImage"] as? Image ?? Image("bannack")
        geoKey = dictionary["g"] as? String ?? ""
    }
   
    
        init(id: Int, name: String, address: Address?, description: String?, moreInfoLink: String?, review: Review?, locationType: String?, cLLocation: CLLocation?, tours: Bool?, imageName: String?, baseImage: Image?, distanceToUser: Double?, price: Double?) {
            self.id = id
            self.name = name
            self.address = address
            self.description = description
            self.moreInfoLink = moreInfoLink
            self.review = review
            self.locationType = locationType
            self.cLLocation = cLLocation
            self.tours = tours
            self.imageName = imageName
            self.baseImage = baseImage
            self.distanceToUser = distanceToUser
            self.price = price
        }
    
    init(id: Int, name: String, cLLocation: CLLocation, baseImage: Image?) {
            self.id = id
            self.name = name
        self.cLLocation = cLLocation
        self.baseImage = baseImage
        }
    
    init(dict: [String : Any]) {
        id = dict["id"] as? Int ?? 00
        name = dict["name"] as? String ?? ""
        imageName = dict["imageName"] as? String ?? ""
    }
    
    
    mutating func addCLoc(_ cllocation: CLLocation) {
        
        var result = self
        
        let address = address?.geoCodeAddress()
        FirebaseManager.instance.getCoordinatesFromAddress(address: address ?? "") { cloc in
            print(cloc.coordinate)
            result.cLLocation = cloc
        }
        self = result
    }

    mutating func addPrice(_ price: Double) {
        var result = self
        result.price = price
        self = result
    }
    
    //MARK: - Images
    struct Images {
        var id: Int
        var imageURL: String
        var locationID: Int
    }
}



struct FavoriteLocation: Identifiable {
    var id: UUID
    var location: Location
    var user: User
    
}


