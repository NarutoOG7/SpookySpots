//
//  LoctionDetails.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LocationDetails: View {
    let location: LocationModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var tripPageVM = TripPageVM.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @State var topBarShouldBeHidden = true
    
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
            ZStack {
                VStack {
                    image
                        .offset(y: geo.frame(in: .global).minY)
                    Spacer()
                }
                //            VStack {
                //                Spacer()
                //
                ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: false, content: {
                    
                    VStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 100, height: 120)
                        VStack(alignment: .leading) {
                            cardHandle
                            title
                            address
                            HStack(alignment: .center) {
                                locationType
                                Spacer()
                                avgRatingDisplay
                            }.padding(.trailing)
                            HStack {
                                Spacer()
                                directionsButton
                                addSubtractTripButton
                                Spacer()
                            }.padding(.bottom)
                            
                            
                            description
                            
                            reviews
                            Spacer()
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 100, height: 180)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0)
                                        .fill(Color.white)
                                        .shadow(color: .black, radius: 10))
                        
                        
                    }
                })
            }
            .navigationBarHidden(topBarShouldBeHidden)
            .navigationBarItems(leading: backButton)
            .navigationBarItems(trailing: favoriteButton)
            
            .onAppear {
                exploreByListVM.searchText = ""
                loadImageFromFirebase()
            }
        }
        }
    }
}


//MARK: - SubViews

extension LocationDetails {
    
    private var image: some View {
        
        NavigationLink {
            FullImageDisplay(location: location)
        } label: {
            WebImage(url: self.imageURL)
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
                .ignoresSafeArea()
        }

        
    }
    
    private var cardHandle: some View {
        HStack {
            
            Spacer()
            RoundedRectangle(cornerRadius: 25.0)
                .frame(width: UIScreen.main.bounds.width / 10, height: 3)
                .offset(y: -10)
            Spacer()
        }
    }
    
    private var title: some View {
        Text(location.location.name)
            .font(.title)
            .fontWeight(.semibold)
            .padding()
    }
    
    private var address: some View {
        Text(location.location.address?.fullAddress() ?? "missing address")
            .fontWeight(.medium)
            .foregroundColor(Color(#colorLiteral(red: 0.4834827094, green: 0.4834827094, blue: 0.4834827094, alpha: 1)))
            .padding(.horizontal)
    }
    
    private var locationType: some View {
        Text(location.location.locationType ?? "")
            .font(.subheadline)
            .fontWeight(.light)
            .foregroundColor(.black)
            .padding()
    }
    
    private var description: some View {
        VStack(alignment: .leading) {
            Divider()
            Text("DESCRIPTION")
                .font(.custom("Avenir", size: 17))
                .fontWeight(.light)
                .foregroundColor(Color(#colorLiteral(red: 0.3913586612, green: 0.3913586612, blue: 0.3913586612, alpha: 0.8491545377)))
            Text(location.location.description ?? "")
                .lineSpacing(7)
                .font(.body)
                .padding(.top, 1)
            
            HStack {
                Text("Get More Info:")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(Color(#colorLiteral(red: 0.3913586612, green: 0.3913586612, blue: 0.3913586612, alpha: 0.8491545377)))
                getMoreInfoButton
                    .padding(.vertical)
            }
        }
        .padding(.bottom)
        
    }
    
    private var avgRatingDisplay: some View {
        HStack {
            FiveStars(location: location.location)
            Text(getAvgRating())
        }
    }
    
    private var reviews: some View {
        VStack(alignment: .trailing) {
            Divider()
            HStack {
                Text("REVIEWS")
                    .font(.custom("Avenir", size: 17))
                    .fontWeight(.light)
                    .foregroundColor(Color(#colorLiteral(red: 0.3913586612, green: 0.3913586612, blue: 0.3913586612, alpha: 0.8491545377)))
                Spacer()
                seeAllReviewsButton
            }
            .padding(.bottom)
            
            HStack {
                
                Spacer()
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(location.location.review?.lastReviewTitle ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .offset(x: 2)
                            FiveStars(location: location.location)
                        }
                        Spacer()
                        Text(location.location.review?.user ?? "")
                            .offset(y: -15)
                    }
                    Text(location.location.review?.lastReview ?? "")
                        .offset(x: 3)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 13)
                                .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                .frame(width: UIScreen.main.bounds.width - 55))
                Spacer()
            }
        }
    }
    
    //MARK: - Buttons
    
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "x.circle")
                .resizable()
                .frame(width: 35, height: 35)
        })
    }
    
    private var addSubtractTripButton: some View {
        VStack {
            StackedCircleButton(
                size: .medium, mainImage: isInTrip() ? Image(systemName: "map.fill") : Image(systemName: "map"),
                secondaryImage: isInTrip() ? Image(systemName: "minus") : Image(systemName: "plus"), outlineColor: .white, iconColor: .white, backgroundColor: .blue, clicked: addOrSubtractFromTrip)
            Text(isInTrip() ? "Remove From Trip" : "Add To Trip")
                .font(.caption2)
                .foregroundColor(Color.blue)
        }
        .frame(width: 100, height: 100)
    }
    
    private var directionsButton: some View {
        VStack {
            CircleButton(size: .medium, image: Image(systemName: "arrow.triangle.turn.up.right.diamond.fill"), outlineColor: .blue, iconColor: .white, backgroundColor: .blue, clicked: getDirections)
            Text("Directions")
                .font(.caption2)
                .foregroundColor(Color.blue)
        }
        .frame(width: 100, height: 100)
    }
    
    private var favoriteButton: some View {
        Button(action: addToFavorites) {
            Image(systemName: "heart")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 50)
        }
    }
    
    private var getMoreInfoButton: some View {
        Button(action: getMoreInfoByUsingWebLink) {
            Text(location.location.moreInfoLink ?? "")
                .underline(true, color: Color(#colorLiteral(red: 0.04680434317, green: 0.3292598999, blue: 0.6950621868, alpha: 0.6714736729)))
                .fontWeight(.light)
                .lineLimit(1)
                .font(.custom("Avenir", size: 15))
                .truncationMode(.middle)
            
        }
    }
    
    private var seeAllReviewsButton: some View {
        Button(action: showAllReviews) {
            Text("See All")
                //                .font(.custom("Avenir", size: 20))
                .font(.custom("Avenir", size: 18))
                .fontWeight(.light)
        }
    }
    
    //MARK: - Methods
    
    func addOrSubtractFromTrip() {
        tripPageVM.trip.addOrSubtractFromTrip(location: location.location)
    }
    func getDirections() {
        // show directions page
    }
    
    func addToFavorites() {
        
    }
    
    func isInTrip() -> Bool {
        tripPageVM.trip.listContainsLocation(location: location.location)
    }
    
    func getMoreInfoByUsingWebLink() {
        
    }
    
    func showAllReviews() {
        // show all reviews on new page
    }
    
    func isAvgRatingAboveOne() -> Bool {
        location.location.review?.avgRating ?? 0 >= 1.0
    }
    
    func getAvgRating() -> String {
        var avgRatingString = ""
        if let review = location.location.review {
            let avgRating = review.avgRating
            if avgRating / avgRating == 1 {
                avgRatingString = "\(avgRating)"
            } else {
                avgRatingString = String(format: "%.1f", avgRating)
            }
            if avgRatingString == "" {
                avgRatingString = "(No Reviews Yet)"
            }
        }
        return avgRatingString
    }
 
    private func loadImageFromFirebase()  {
        if let imageString = location.location.imageName {
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                self.imageURL = url
            }
        }
    }
}


struct LocationDetails_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetails(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}
