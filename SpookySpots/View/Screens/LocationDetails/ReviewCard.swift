//
//  ReviewCard.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct ReviewCard: View {
    
    let review: ReviewModel
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack(alignment: .leading,spacing: 7) {
            title
            stars
                .padding(.bottom, 6)
            description
            name
                .padding(.trailing, 15)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 14)
            .strokeBorder(weenyWitch.brown, lineWidth: 3))
    }
    
    var title: some View {
        Text(review.title)
            .font(.avenirNext(size: 20))
            .fontWeight(.medium)
            .foregroundColor(weenyWitch.brown)
    }
    
    var stars: some View {
        FiveStars(color: weenyWitch.orange,
                  rating: .constant(review.rating))
    }
    
    var description: some View {
        Text(review.review)
            .font(.avenirNext(size: 17))
            .fontWeight(.light)
            .foregroundColor(weenyWitch.brown)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    var name: some View {
        HStack {
            Spacer()
            Text("-\(review.username)")
                .font(.avenirNext(size: 17))
                .fontWeight(.medium)
                .foregroundColor(weenyWitch.brown)
        }
    }
}

struct ReviewCard_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCard(review: ReviewModel(id: "",
                                       rating: 4,
                                       review: "Loved the room and it is soo haunted!",
                                       title: "Definite Yes",
                                       username: "ALA",
                                       locationID: "123",
                                       locationName: "Stanley Hotel"))
    }
}
