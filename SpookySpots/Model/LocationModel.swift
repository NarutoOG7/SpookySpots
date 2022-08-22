//
//  LocationModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/25/22.
//

import Foundation

struct LocationModel: Identifiable, Equatable {
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        lhs.location.id == rhs.location.id
    }
    
    
    var id = UUID()
    var location: LocationData
    var imageURLs: [URL]
    var reviews: [ReviewModel]
    
    var mainImageURL: URL? {
        imageURLs.first
    }
    
    static let example = LocationModel(location: LocationData.example, imageURLs: [], reviews: [])
    
    
    
    func getAvgRatingIntAndString() -> (number: Int, string: String) {
        var avgRatingString = ""
        var avgRatingDouble = 0
        if let review = location.review {
            avgRatingDouble = Int(review.avgRating)
//            if avgRating / avgRating == 1 {
//                avgRatingString = "\(avgRating)"
//            } else {
//                avgRatingString = String(format: "%.1f", avgRating)
//            }
            avgRatingString = String(format: "%g", avgRatingDouble)
            
            if avgRatingString == "" {
                avgRatingString = "(No Reviews Yet)"
            }
        }
        return (avgRatingDouble , avgRatingString)
    }
    
}
