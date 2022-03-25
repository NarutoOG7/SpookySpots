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

struct Location: Identifiable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    

    static let example = Location(id: 1111,
                             name: "Bannack",
                             address: Address(address: "721 Bannack Rd", city: "Dillon", state: "MT", zipCode: "59725", country: "USA"),
                             description: "Bannack State Park is a National Historic Landmark and is the best preserved of all Montana ghost towns. Back in the “Old West”, during the mighty gold rush of 1862, Bannack’s population grew over 3,000. Today, no residents remain in this town.",
                             moreInfoLink: "https://fwp.mt.gov/stateparks/bannack-state-park",
                             review: Location.Review(avgRating: 5, lastRating: 5, lastReview: "Must visit anytime you are in Montana!", lastReviewTitle: "Breathtaking", user: "Spencer"),
                             locationType: "Ghost Town",
                                  cLLocation: nil,
                             tours: true,
                             imageName: "FairbanksBridge.jpg",
                             baseImage: nil,
                             distanceToUser: nil)
    
    var id: Int
    var name: String
    var address: Address?
    var description: String?
    var moreInfoLink: String?
    var review: Review?
    var locationType: String?
    var cLLocation: CLLocation?
    var tours: Bool?
    var imageName: String?
    var baseImage: Image?
    var distanceToUser: Double?
    
    init(id: Int, name: String, address: Address?, description: String?, moreInfoLink: String?, review: Review?, locationType: String?, cLLocation: CLLocation?, tours: Bool?, imageName: String?, baseImage: Image?, distanceToUser: Double?) {
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
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    
    mutating func assignCoordinates(cLLocation: CLLocation) {
        self.cLLocation = cLLocation
    }
    
    
    
    
    struct Review {
        var avgRating: Double
        var lastRating: Int
        var lastReview: String
        var lastReviewTitle: String
        var user: String
    }
    
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


