//
//  FiveStars.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct FiveStars: View {
    var location: Location
    
    var body: some View {
         HStack(alignment: .top) {
            StarIcon(filled: location.review?.avgRating ?? 0 > 0)
            StarIcon(filled: location.review?.avgRating ?? 0 > 1)
            StarIcon(filled: location.review?.avgRating ?? 0 > 2)
            StarIcon(filled: location.review?.avgRating ?? 0 > 3)
            StarIcon(filled: location.review?.avgRating ?? 0 > 4)
        }
    }
}

struct StarIcon: View {
    var filled: Bool = true
    var body: some View {
        Image(systemName: filled ? "star.fill" : "star")
            .foregroundColor(filled ? Color.yellow : Color.black.opacity(0.6))
    }
}


struct FiveStars_Previews: PreviewProvider {
    static var previews: some View {
        FiveStars(location: Location.example)
    }
}
