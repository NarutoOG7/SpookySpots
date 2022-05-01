//
//  Review.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct Review: Codable {
    var avgRating: Double
    var lastRating: Int
    var lastReview: String
    var lastReviewTitle: String
    var userName: String
}

struct ReviewModel {
    var avgRating: Double
    var lastRating: Int
    var lastReview: String
    var lastReviewTitle: String
    var userName: String
    
    init(dictionary: [String:Any]) {
        self.userName = dictionary["userName"] as? String ?? ""
        self.avgRating = dictionary["avgRating"] as? Double ?? 0
        self.lastRating = dictionary["lastRating"] as? Int ?? 0
        self.lastReview = dictionary["lastReview"] as? String ?? ""
        self.lastReviewTitle = dictionary["lastReviewTitle"] as? String ?? ""
    }
}
