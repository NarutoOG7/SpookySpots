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
    var user: String
}
