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
    
//    init(snapshot: DataSnapshot) {
//        let data = snapshot.value as? [String : AnyObject]
//            id = data?["id"] as? Int ?? Int.random(in: 200...300)
//            name = data?["name"] as? String ?? ""
//            address = Address(
//                    address: data?["street"] as? String ?? "",
//                    city: data?["city"] as? String ?? "",
//                    state: data?["state"] as? String ?? "",
//                    zipCode: data?["zipCode"] as? String ?? "",
//                    country: data?["country"] as? String ?? "")
//            description = data?["description"] as? String ?? ""
//            moreInfoLink = data?["moreInfoLink"] as? String ?? ""
//            review = Review(
//                    avgRating: data?["avgRating"] as? Double ?? 0,
//                    lastRating: data?["lastRating"] as? Int ?? 0,
//                    lastReview: data?["lastReview"] as? String ?? "",
//                    lastReviewTitle: data?["lastReviewTitle"] as? String ?? "",
//                    user: data?["lastReviewUser"] as? String ?? "")
//            imageName = data?["imageName"] as? String ?? ""
//            tours = data?["offersGhostTours"] as? Bool ?? false
//            hours = data?["hoursOfOperation"] as? String ?? ""
//            hotelKey = data?["hotelKey"] as? String ?? ""
//            cLLocation = CLLocation(
//                    latitude: data?["l/0"] as? Double ?? 0,
//                    longitude: data?["l/1"] as? Double ?? 0)
//
//        FirebaseManager().getImageFromURLString(imageName) { image in
//
//        }
//
//    }
    
//    func toAnyObject() -> Any {
//       return [
//        "avgRating": review?.avgRating ?? "",
//        "city": address?.city ?? "",
//        "country": address?.country ?? "",
//        "description": description,
//        "hotelKey": hotelKey,
//        "hoursOfOperation": hours,
//        "id": id,
//        "imageName": imageName,
//        "lastRating": review?.lastRating ?? "",
//        "lastReview": review?.lastReview ?? "",
//        "lastReviewTitle": review?.lastReviewTitle ?? "",
//        "lastReviewUser": review?.user ?? "",
//        "likes": likes,
//        "moreInfoLink": moreInfoLink,
//        "name": name,
//        "offersGhostTours": tours,
//        "state": address?.state ?? "",
//        "street": address?.address ?? "",
//        "zipCode": address?.zipCode ?? ""
//       ]
//     }
//
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
    
    
    
    //    mutating func assignCoordinates(cLLocation: CLLocation) {
    //        self.cLLocation = cLLocation
    //    }
    //
    //
    
    
    
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


