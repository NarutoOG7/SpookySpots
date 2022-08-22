//
//  Review.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct Review: Codable {
    var avgRating: Double = 0
    var lastRating: Int = 0
    var lastReview: String = ""
    var lastReviewTitle: String = ""
    var userName: String = ""
    var locationID: String
}

struct ReviewModel {
    var avgRating: Double = 0
    var lastRating: Int = 0
    var lastReview: String = ""
    var lastReviewTitle: String = ""
    var userName: String = ""
    var locationID: String
    
    init(avgRating: Double, lastRating: Int, lastReview: String, lastReviewTitle: String, userName: String, locationID: String) {
        self.avgRating = avgRating
        self.lastRating = lastRating
        self.lastReview = lastReview
        self.lastReviewTitle = lastReviewTitle
        self.userName = userName
        self.locationID = locationID
    }
    
    init(dictionary: [String:Any]) {
        self.userName = dictionary["userName"] as? String ?? ""
        self.avgRating = dictionary["avgRating"] as? Double ?? 0
        self.lastRating = dictionary["lastRating"] as? Int ?? 0
        self.lastReview = dictionary["lastReview"] as? String ?? ""
        self.lastReviewTitle = dictionary["lastReviewTitle"] as? String ?? ""
        self.locationID = dictionary["locationID"] as? String ?? ""
    }
}
