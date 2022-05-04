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
    var reviews: [Review]
    
    var mainImageURL: URL? {
        imageURLs.first
    }
    
    static let example = LocationModel(location: LocationData.example, imageURLs: [], reviews: [])
    
    
    
    func getAvgRating() -> String {
        var avgRatingString = ""
        if let review = location.review {
            let avgRating = review.avgRating
//            if avgRating / avgRating == 1 {
//                avgRatingString = "\(avgRating)"
//            } else {
//                avgRatingString = String(format: "%.1f", avgRating)
//            }
            avgRatingString = String(format: "%g", avgRating)
            
            if avgRatingString == "" {
                avgRatingString = "(No Reviews Yet)"
            }
        }
        return avgRatingString
    }
    
}
