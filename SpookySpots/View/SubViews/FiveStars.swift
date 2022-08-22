//
//  FiveStars.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct FiveStars: View {
    @Binding var rating: Int
    var isEditable = false
    let color: Color
    var body: some View {
         HStack {
             ForEach(1...5, id: \.self) { index in
                 Image(systemName: self.starImageNameFromRating(index))
                     .foregroundColor(color)
                     .onTapGesture {
                         if isEditable {
                             self.rating = index
                         }
                     }
             }
        }
    }
    
    private func starImageNameFromRating(_ index: Int) -> String {
            return index <= rating ? "star.fill" : "star"
    }
}


struct FiveStars_Previews: PreviewProvider {
    static var previews: some View {
        FiveStars(
            rating: .constant(3),
            isEditable: true,
            color: K.Colors.WeenyWitch.orange)
    }
}
