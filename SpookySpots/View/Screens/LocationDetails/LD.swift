//
//  LD.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/27/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LD: View {
    
    @State var location: LocationModel
        
    @State private var imageURL = URL(string: "")
    @State private var isSharing = false
    @State private var imageIsAvailable = false
    
    @EnvironmentObject var favoritesLogic: FavoritesLogic
    @EnvironmentObject var tripLogic: TripLogic

    let imageMaxHeight = UIScreen.main.bounds.height * 0.38
    let collapsedImageHeight: CGFloat = 10
    
    
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
                    }
                    .sheet(isPresented: $isSharing) {
                        ShareActivitySheet(itemsToShare: [location.location.name])
                    }
            }
            .background(Image(K.Images.paperBackground).opacity(0.5))
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
                .frame(width: geo.size.width, height: self.calculateHeight(minHeight: collapsedImageHeight, maxHeight: imageMaxHeight, yOffset: geo.frame(in: .global).origin.y))
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
            .font(.avenirNextRegular(size: 17))
            .lineLimit(nil)
            .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    private var avgRatingDisplay: some View {
        HStack {
            FiveStars(
                rating: $location.avgRating,
                color: K.Colors.WeenyWitch.orange)
            Text("")
        }
    }
    
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
    
    private var description: some View {
            Text(location.location.description ?? "")
                .font(.avenirNext(size: 17))
                .lineLimit(nil)
                .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    private var reviewHelper: some View {
        VStack(alignment: .leading) {
//            if location.location.review?.lastReview == "" {
            if location.reviews.isEmpty {
                Divider()
                Text("No Reviews")
                    .foregroundColor(K.Colors.WeenyWitch.brown)
            } else {
                if let last = location.reviews.last {
                    
                    ReviewCard(review: last)
                }
            }
            leaveAReviewView
                .padding(.vertical)
            Spacer(minLength: 200)
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
        let locReviewView = LocationReviewView(location: $location)
        return VStack(alignment: .leading) {
            Text("Been here before?")
                .italic()
                .foregroundColor(K.Colors.WeenyWitch.brown)
            NavigationLink(destination: locReviewView) {
                Text("Leave A Review")
                    .underline()
                    .foregroundColor(K.Colors.WeenyWitch.orange)
            }
//            }.onDisappear {
//                self.location = locReviewView.location
//            }
        }
    }
    
    //MARK: - Buttons
    
    private var directionsButton: some View {
//        BorderedCircularButton(
//            image: Image(systemName: ),
//            title: "Directions",
//            color: K.Colors.WeenyWitch.brown,
//            tapped: directionsTapped)
        CircleButton(
            size: .medium,
            image: Image(systemName: K.Images.directions),
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: "Directions",
            clicked: directionsTapped)
    }
    
    private var shareButton: some View {
//        BorderedCircularButton(
//            image: Image(systemName: K.Images.share),
//            title: "Share",
//            color: K.Colors.WeenyWitch.brown,
//            tapped: shareTapped)
//
        CircleButton(
            size: .medium,
            image: Image(systemName: K.Images.share),
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: "Share",
            clicked: shareTapped)
    }
    
    
    
//    private var addRemoveFromTrip: some View {
//        BorderedCircularButton(
//            image: Image(systemName: "plus"),
//            title: "Add To Trip",
//            color: .green,
//            tapped: addToTripTapped)
//    }
//
    private var addRemoveFromTrip: some View {
//        BorderedCircularButton(
//            image: Image(systemName: tripLogic.destinationsContains(location) ? "minus" : "plus"),
//            title: tripLogic.destinationsContains(location) ? "Remove From Trip" : "Add To Trip",
//            color: K.Colors.WeenyWitch.brown,
//            tapped: addToTripTapped)
//
        CircleButton(
            size: .medium,
            image: Image(systemName: tripLogic.destinationsContains(location) ? "minus" : "plus"),
            mainColor: K.Colors.WeenyWitch.brown,
            accentColor: K.Colors.WeenyWitch.lightest,
            title: tripLogic.destinationsContains(location) ? "Remove From Trip" : "Add To Trip",
            clicked: addToTripTapped)
    }
    private var favoriteButton: some View {
//        BorderedCircularButton(
//            image: favoritesLogic.contains(location) ?
//                Image(systemName: "heart.fill") :
//                Image(systemName: "heart"),
//            title: "Favorites",
//            color: K.Colors.WeenyWitch.brown,
//            tapped: favoritesTapped)
//
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
        // Open directions in apple maps //move!!
        // need to test with all locations... may need to use address instead of location name
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
    
    private func moreReviewsTapped() {
        
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
        LD(location: LocationModel.example)
            .environmentObject(FavoritesLogic())
            .environmentObject(TripLogic())
    }
}



//MARK: - Sticky Header Helpers

extension LD {
    
    /////MARK: - Calculate Height
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
    
    
    /////MARK: - Header Shadow
    func calculateShadow(_ geo: GeometryProxy) -> Double {
        self.calculateHeight(
            minHeight: collapsedImageHeight,
            maxHeight: imageMaxHeight,
            yOffset: geo.frame(in: .global).origin.y) < 140 ? 8 : 0
    }
    
    /////MARK: - Blur Image
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
}


//MARK: - Share Activity View
struct ShareActivitySheet: UIViewControllerRepresentable {
    
    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareActivitySheet>) -> UIActivityViewController {
        
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareActivitySheet>) { }
}


struct ReviewCard: View {
    let review: ReviewModel
    
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
            .strokeBorder(K.Colors.WeenyWitch.brown, lineWidth: 3))
//            .stroke(K.Colors.WeenyWitch.brown, lineWidth: 4))
    }
    
    var title: some View {
        Text(review.title)
            .fontWeight(.medium)
            .foregroundColor(K.Colors.WeenyWitch.brown)
    }
    
    var stars: some View {
        FiveStars(rating: .constant(review.rating), color: K.Colors.WeenyWitch.orange)
    }
    
    var description: some View {
        Text(review.review)
            .fontWeight(.light)
            .foregroundColor(K.Colors.WeenyWitch.brown)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    var name: some View {
        HStack {
            Spacer()
            Text("-\(review.username)")
                .fontWeight(.medium)
                .foregroundColor(K.Colors.WeenyWitch.brown)
        }
    }
}
