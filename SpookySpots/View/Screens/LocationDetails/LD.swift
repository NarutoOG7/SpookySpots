//
//  LD.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/27/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LD: View {
    
    @Binding var location: LocationModel
    
    @State private var imageURL = URL(string: "")
    @State private var isSharing = false
    @State private var isCreatingNewReview = false
    @State private var isShowingMoreReviews = false
    
    @EnvironmentObject var favoritesLogic: FavoritesLogic
    @EnvironmentObject var tripLogic: TripLogic
    
    let imageMaxHeight = UIScreen.main.bounds.height * 0.38
    let collapsedImageHeight: CGFloat = 10
    
    private let images = K.Images.self
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(alignment: .leading, spacing: 7) {
                    title
                    address
                    avgRatingDisplay
                    buttons
                    Divider()
                    description
                    Spacer()
                    moreInfoLink
                    Spacer()
                    reviewHelper
                }
                .clipped()
                .padding(.horizontal)
                .padding(.vertical, imageMaxHeight + 36.0)
                
                
                image
                
                VStack {
                    HStack {
                        backButton
                        Spacer()
                    }.padding(.horizontal)
                        .padding(.top, 60)
                    Spacer()
                }
                
                .onAppear {
                    loadImageFromFirebase()
                    print(location.reviews.count)
                }
                .sheet(isPresented: $isSharing) {
                    ShareActivitySheet(itemsToShare: [location.location.name])
                }
                
                .sheet(isPresented: $isShowingMoreReviews) {
                    MoreReviewsSheet(reviews: location.reviews)
                }
            }
            .background(K.Images.paperBackground)
        }
        .edgesIgnoringSafeArea(.vertical)
        .navigationBarHidden(true)
    }
    
    //MARK: - SubViews
    
    private var header: some View {
        HStack {
            backButton
                .padding(.horizontal)
            Spacer()
            headerText
                .padding(.horizontal)
            Spacer()
            Spacer()
        }
        .offset(y: 80)
        
    }
    
    private var headerText: some View {
        Text(location.location.name)
            .font(.avenirNext(size: 20))
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    private var image: some View {
        GeometryReader { geo in
            WebImage(url: self.imageURL)
                .resizable()
                .aspectRatio(1.75, contentMode: .fill)
                .blur(radius: self.getBlurRadiusForImage(geo))
                .shadow(radius: self.calculateShadow(geo))
                .overlay(header
                    .opacity(self.getBlurRadiusForImage(geo) - 0.35))
                .frame(width: geo.size.width,
                       height: self.calculateHeight(minHeight: collapsedImageHeight,
                                                    maxHeight: imageMaxHeight,
                                                    yOffset: geo.frame(in: .global).origin.y))
                .offset(y: geo.frame(in: .global).origin.y < 0
                        ? abs(geo.frame(in: .global).origin.y)
                        : -geo.frame(in: .global).origin.y)
            
        }
    }
    
    private var title: some View {
        Text(location.location.name)
            .font(.avenirNext(size: 34))
            .fontWeight(.medium)
            .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    
    private var address: some View {
        Text(location.location.address?.fullAddress() ?? "")
            .font(.avenirNextRegular(size: 19))
            .lineLimit(nil)
            .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    private var avgRatingDisplay: some View {
        HStack {
            FiveStars(
                color: K.Colors.WeenyWitch.orange,
                rating: $location.avgRating)
            let reviewCount = location.reviews.count
            let textEnding = reviewCount == 1 ? "" : "s"
            Text("(\(reviewCount) review\(textEnding))")
                .font(.avenirNextRegular(size: 17))
                .foregroundColor(K.Colors.WeenyWitch.brown)
        }
    }
    

    private var description: some View {
        Text(location.location.description ?? "")
            .font(.avenirNext(size: 17))
            .lineLimit(nil)
            .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    private var reviewHelper: some View {
        VStack(alignment: .leading) {
            if location.reviews.isEmpty {
                Divider()
                Text("No Reviews")
                    .foregroundColor(K.Colors.WeenyWitch.brown)
            } else {
                if let last = location.reviews.last {
                    ReviewCard(review: last)
                    
                }
            }
            HStack {
                leaveAReviewView
                if location.reviews.count > 1 {
                    moreReviewsButton
                }
            }
                .padding(.vertical, 30)
            Spacer(minLength: 200)
        }
        .sheet(isPresented: $isCreatingNewReview) {
            LocationReviewView(location: $location, isPresented: $isCreatingNewReview, review: .constant(nil))
        }
    }
    
    private var moreInfoLink: some View {
        
        let view: AnyView
        
        if let url = URL(string: location.location.moreInfoLink ?? "") {
            
            view = AnyView(
                HStack {
                    Spacer()
                    Link(destination: url, label: {
                        Text("Get More Info")
                            .underline()
                            .foregroundColor(K.Colors.WeenyWitch.orange)
                    })
                }
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var leaveAReviewView: some View {
        
        VStack(alignment: .leading) {
            Text("Been here before?")
                .italic()
                .foregroundColor(K.Colors.WeenyWitch.brown)
            Button {
                self.isCreatingNewReview = true
                
            } label: {
                Text("Leave A Review")
                    .underline()
                    .foregroundColor(K.Colors.WeenyWitch.orange)
            }
        }
    }
    
    //MARK: - Buttons
    
    var buttons: some View {
        HStack(alignment: .top) {
            Spacer()
            directionsButton
            shareButton
            addRemoveFromTrip
            favoriteButton
            Spacer()
        }.padding(.top)
            .frame(height: 150)
    }
    
    
    private var directionsButton: some View {
        CircleButton(
            size: .medium,
            image: images.directions,
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: "Directions",
            clicked: directionsTapped)
    }
    
    private var shareButton: some View {
        CircleButton(
            size: .medium,
            image: images.share,
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: "Share",
            clicked: shareTapped)
    }

    private var addRemoveFromTrip: some View {
        CircleButton(
            size: .medium,
            image: Image(systemName: tripLogic.destinationsContains(location) ? "minus" : "plus"),
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: tripLogic.destinationsContains(location) ? "Remove From Trip" : "Add To Trip",
            clicked: addToTripTapped)
    }
    
    private var favoriteButton: some View {
        CircleButton(
            size: .medium,
            image: favoritesLogic.contains(location) ?
            Image(systemName: "heart.fill") :
                Image(systemName: "heart"),
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: "Favorites",
            clicked: favoritesTapped)
    }
    
    private var moreReviewsButton: some View {
        HStack {
            Spacer()
            Button(action: moreReviewsTapped) {
                Text("More Reviews")
                    .font(.avenirNextRegular(size: 17))
                    .fontWeight(.medium)
            }
        }.padding(.vertical)
    }
    
    private var backButton: some View {
        Button(action: backButtonTapped) {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 25, height: 35)
                .tint(K.Colors.WeenyWitch.orange)
        }
    }
    
    
    //MARK: - Methods
    
    private func directionsTapped() {

        var addressString: String {
            
            location.location.name.replacingOccurrences(of: " ", with: "+")
        }
        
        guard let url = URL(string: "maps://?daddr=\(addressString)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func shareTapped() {
        self.isSharing = true
    }
    
    private func addToTripTapped() {
        
        if tripLogic.destinationsContains(location) {
            
            tripLogic.removeDestination(location)
            
        } else {
            
            tripLogic.addDestination(location)
        }
    }
    
    private func backButtonTapped() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func favoritesTapped() {
        
        if favoritesLogic.contains(location) {
            
            favoritesLogic.removeHotel(location)
        } else {
            favoritesLogic.addHotel(location)
        }
    }
    
    private func moreReviewsTapped() {
        self.isShowingMoreReviews = true
    }
    
    
    private func loadImageFromFirebase()  {
        
        if let imageString = location.location.imageName {
            
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                
                self.imageURL = url
            }
        }
    }
}

//MARK: - Previews
struct LD_Previews: PreviewProvider {
    static var previews: some View {
        LD(location: .constant(LocationModel.example))
            .environmentObject(FavoritesLogic())
            .environmentObject(TripLogic())
    }
}



//MARK: - Sticky Header Helpers

extension LD {
    
    private func calculateHeight(minHeight: CGFloat, maxHeight: CGFloat, yOffset: CGFloat) -> CGFloat {
        /// If scrolling up, yOffset will be a negative number
        if maxHeight + yOffset < minHeight {
            /// SCROLLING UP
            /// Never go smaller than our minimum height
            return minHeight
        }
        /// SCROLLING DOWN
        return maxHeight + yOffset
    }
    
    func calculateShadow(_ geo: GeometryProxy) -> Double {
        self.calculateHeight(
            minHeight: collapsedImageHeight,
            maxHeight: imageMaxHeight,
            yOffset: geo.frame(in: .global).origin.y) < 140 ? 8 : 0
    }
    
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
}

