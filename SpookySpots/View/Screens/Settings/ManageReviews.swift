//
//  ManageReviews.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/28/22.
//

import SwiftUI

struct ManageReviews: View {
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var locationStore = LocationStore.instance
    
    @State private var reviews: [ReviewModel] = []
    
    @State private var selectedReview: ReviewModel?
    @State private var isEditingReview = false
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            weenyWitch.black
                .edgesIgnoringSafeArea(.all)

            if userStore.reviews.isEmpty {
                 noReviews
            } else {
            listOfReviews
                    .padding(.vertical, 30)
            }
        }
        .sheet(item: $selectedReview, content: { review in
            LocationReviewView(
                location: .constant(review.location ?? LocationModel.example),
                isPresented: $isEditingReview,
                review: $selectedReview,
                titleInput: review.title,
                pickerSelection: review.rating,
                descriptionInput: review.review,
                isAnonymous: review.username == "Anonymous",
                nameInput: review.username
            )
        })
        
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.large)
        
            .onAppear {
                userStore.reviews = []
                firebaseManager.getReviewsForUser(userStore.user) { rev in
                    
                    var review = rev
                    if let location = locationStore.hauntedHotels.first(where: { "\($0.location.id)" == review.locationID }) {
                        review.location = location
                    }
                    
                    userStore.reviews.append(review)
                    print(review.title)
                }
                
                UITableView.appearance().backgroundColor = .clear
            }
    }
    
    private var noReviews: some View {
        Text("No Reviews")
            .foregroundColor(weenyWitch.lightest)
            .font(.title3)
    }
    
    private var listOfReviews: some View {

             List {
                ForEach(userStore.reviews, id: \.self) { review in
                    Button(action: {
                        self.selectedReview = review
                        self.isEditingReview = true
                        
                    }, label: {
                        Text(review.title)
                    })
                    .listRowBackground(weenyWitch.lightest)
                    
                }
                .onDelete(perform: delete)
            }
                .listStyle(.insetGrouped)
            
    }
    
    private func delete(at offsets: IndexSet) {
        
        offsets.map { userStore.reviews[$0] }.forEach { review in
            firebaseManager.removeReviewFromFirestore(review)
        }
        
        userStore.reviews.remove(atOffsets: offsets)
    }
}

struct ManageReviews_Previews: PreviewProvider {
    static var previews: some View {
        ManageReviews()
    }
}
