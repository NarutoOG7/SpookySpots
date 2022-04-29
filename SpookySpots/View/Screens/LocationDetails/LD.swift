//
//  LD.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/27/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LD: View {
    
    var location: LocationModel
    
    @State private var imageURL = URL(string: "")
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    
    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    
    let imageMaxHeight = UIScreen.main.bounds.height * 0.38
    let collapsedImageHeight: CGFloat = 10
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading, spacing: 7) {
                    title
                    address
                    avgRatingDisplay
                    
                    HStack(spacing: 26) {
                        Spacer()
                        directionsButton
                        shareButton
                        addToTripButton
                        Spacer()
                    }.padding(.vertical)
                    
                    Divider()
                    description
                    Spacer()
                    mainReview
                    Spacer()
                    moreInfoLink
                }
                .padding(.horizontal)
                .padding(.vertical, imageMaxHeight + 16.0)
            
                
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
        }
        }.edgesIgnoringSafeArea(.vertical)
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
            .font(.avenirNext(size: 28))
            .fontWeight(.bold)
            .foregroundColor(.white)
//            .offset(y: 80)
    }
    
    private var image: some View {
        GeometryReader { geo in
            WebImage(url: self.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: self.getBlurRadiusForImage(geo))
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
            .font(.avenirNext(size: 28))
            .background(GeometryGetter(rect: self.$titleRect))
    }
    
    
    private var address: some View {
        Text(location.location.address?.fullAddress() ?? "")
            .font(.avenirNextRegular(size: 17))
            .lineLimit(nil)
            .foregroundColor(Color(red: 73/255, green: 77/255, blue: 73/255))
        //            .padding(.top, 1)
    }
    
    private var avgRatingDisplay: some View {
        HStack {
            FiveStars(location: location.location)
            Text(location.getAvgRating())
                .font(.avenirNext(size: 15))
                .foregroundColor(Color(red: 120/255, green: 120/255, blue: 120/255))
                .offset(y: 1)
        }
    }
    
    private var description: some View {
        VStack {
        Text(location.location.description ?? "")
            .font(.avenirNext(size: 17))
            .lineLimit(nil)
            Text(location.location.description ?? "")
                .font(.avenirNext(size: 17))
                .lineLimit(nil)
            Text(location.location.description ?? "")
                .font(.avenirNext(size: 17))
                .lineLimit(nil)
        }
    }
    
    private var mainReview: some View {
        VStack(alignment: .leading) {
            Divider()
            HStack {
                Text(location.location.review?.lastReviewTitle ?? "")
                    .font(.avenirNext(size: 23))
                Spacer()
                FiveStars(location: location.location)
            }
            
            Text(location.location.review?.lastReview ?? "")
                .font(.avenirNextRegular(size: 17))
                .padding(.vertical, 1)
            moreReviewsButton
        }
    }
    
    private var moreInfoLink: some View {
        let view: AnyView
        if let url = URL(string: location.location.moreInfoLink ?? "") {
            view = AnyView(Link("Get More Info", destination: url))
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    //MARK: - Buttons
    
    private var directionsButton: some View {
        BorderedCircularButton(image: Image(systemName: "arrow.triangle.turn.up.right.diamond.fill"), color: .green, tapped: directionsTapped)
    }
    
    private var shareButton: some View {
        BorderedCircularButton(
            image: Image(systemName: "square.and.arrow.up"),
            color: .green,
            tapped: shareTapped)
    }
    
    private var addToTripButton: some View {
        BorderedCircularButton(image: Image(systemName: "plus"), color: .green, tapped: addToTripTapped)
    }
    
    private var moreReviewsButton: some View {
        HStack {
            Spacer()
            Button(action: moreReviewsTapped) {
                Text("More Reviews")
            }
        }.padding(.vertical)
    }
    
    private var backButton: some View {
        Button(action: backButtonTapped) {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 25, height: 35)
                .tint(.cyan)
        }
        
    }
    
    private var favoriteButton: some View {
        Button(action: favoritesTapped) {
            Image(systemName: "heart")
                .resizable()
                .frame(width: 35, height: 35)
                .tint(.red)
        }
    }
    
    //MARK: - Methods
    
    private func directionsTapped() {
        // Open directions in apple maps
    }
    
    private func shareTapped() {
        
    }
    
    private func addToTripTapped() {
        
    }
    
    private func moreReviewsTapped() {
        
    }
    
    private func backButtonTapped() {
        
    }
    
    private func favoritesTapped() {
        
    }
    
    private func calculateHeight(minHeight: CGFloat, maxHeight: CGFloat, yOffset: CGFloat) -> CGFloat {
        // If scrolling up, yOffset will be a negative number
        if maxHeight + yOffset < minHeight {
            // SCROLLING UP
            // Never go smaller than our minimum height
            return minHeight
        }
        
        // SCROLLING DOWN
        return maxHeight + yOffset
    }
    
    private func loadImageFromFirebase()  {
        if let imageString = location.location.imageName {
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                self.imageURL = url
            }
        }
    }
}

struct LD_Previews: PreviewProvider {
    static var previews: some View {
        LD(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}



//MARK: - Sticky Header Helpers

extension LD {
    
    /////MARK: - Get Scroll Offset
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    
    /////MARK: - Blur Image
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
    
    /////MARK: - Header Title Offset
    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY
        
        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0
            let maxYValue: CGFloat = collapsedImageHeight
            let currentYValue = currentYPos

            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))
            let finalOffset: CGFloat = -30.0
            
            return 20 - (percentage * finalOffset)
        }
        
        return .infinity
    }
    

    /////MARK: - Get Image Height
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
//        let imageHeight = self.imageMaxHeight
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
    
    
    /////MARK: - Offset For Image
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageMaxHeight - collapsedImageHeight
        
        if offset < -sizeOffScreen {

            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            return imageOffset - sizeOffScreen
        }
        
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
}


class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}


struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
