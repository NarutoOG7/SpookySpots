//
//  Review.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct Review: Codable {
    var rating: Int = 0
    var review: String = ""
    var title: String = ""
    var username: String = ""
    var locationID: String
}

struct ReviewModel {
    var rating: Int = 0
    var review: String = ""
    var title: String = ""
    var username: String = ""
    var locationID: String
    
    init(rating: Int, review: String, title: String, username: String, locationID: String) {
        self.rating = rating
        self.review = review
        self.title = title
        self.username = username
        self.locationID = locationID
    }
    
    init(dictionary: [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.rating = dictionary["rating"] as? Int ?? 0
        self.review = dictionary["review"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.locationID = dictionary["locationID"] as? String ?? ""
    }
}
