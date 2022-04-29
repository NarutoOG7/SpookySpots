//
//  LocDetails.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/26/22.
//

import SwiftUI
import SDWebImageSwiftUI


extension Font {
    static func avenirNext(size: Int) -> Font {
        return Font.custom("Avenir Next", size: CGFloat(size))
    }
    
    static func avenirNextRegular(size: Int) -> Font {
        return Font.custom("AvenirNext-Regular", size: CGFloat(size))
    }
}



struct LocDetails: View {
    
    var location: LocationModel
    
     private let imageHeight: CGFloat = 300
     private let collapsedImageHeight: CGFloat = 75
     
     @ObservedObject private var articleContent: ViewFrame = ViewFrame()
     @State private var titleRect: CGRect = .zero
     @State private var headerImageRect: CGRect = .zero
     

     var body: some View {
         ScrollView {
             VStack {
                 VStack(alignment: .leading, spacing: 10) {
                      
                     title
                     address
                     avgRatingDisplay
                     directionsButton
                 }
                 .padding(.horizontal)
                 .padding(.top, 16.0)
             }
             .offset(y: imageHeight + 16)
             .background(GeometryGetter(rect: $articleContent.frame))
             
             GeometryReader { geometry in
      
                 ZStack(alignment: .bottom) {
                     image
                         .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                         .blur(radius: self.getBlurRadiusForImage(geometry))

                     headerText
                 }
                 .clipped()
                 .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
             }
             .frame(height: imageHeight)
             .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
         }.edgesIgnoringSafeArea(.all)
     }
    
    
    //MARK: - SubViews
    
    private var image: some View {

        Image("bannack")
            .resizable()
            .scaledToFill()
            .clipped()
            .background(GeometryGetter(rect: self.$headerImageRect))
    }
    
    private var headerText: some View {
        Text("Bannack")
            .font(.avenirNext(size: 17))
            .foregroundColor(.white)
            .offset(x: 0, y: self.getHeaderTitleOffset())
    }
    
    private var title: some View {
        Text("Bannack")
            .font(.avenirNext(size: 28))
            .background(GeometryGetter(rect: self.$titleRect))
    }
    
    private var address: some View {
        Text(location.location.address?.fullAddress() ?? "")
            .font(.avenirNextRegular(size: 17))
            .lineLimit(nil)
    }
    
    private var avgRatingDisplay: some View {
        HStack {
            FiveStars(location: location.location)
            Text(getAvgRating())
        }
    }
    
    
    //MARK: - Buttons
    
    private var directionsButton: some View {
        Button(action: directionsTapped) {
            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                .tint(.green)
                .padding()
                .background(Circle().tint(.white).padding(2).background(Circle().tint(.green)))
        }
    }
    
    
    //MARK: - Methods
    
    private func directionsTapped() {
        // Open directions in apple maps
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
}

struct LocDetails_Previews: PreviewProvider {
    static var previews: some View {
        LocDetails(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}






//MARK: - Parallax Scroll View Helpers
extension LocDetails {
    
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        if offset < -sizeOffScreen {

            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            return imageOffset - sizeOffScreen
        }
        
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
    
    
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
}
//
//class ViewFrame: ObservableObject {
//    var startingRect: CGRect?
//    
//    @Published var frame: CGRect {
//        willSet {
//            if startingRect == nil {
//                startingRect = newValue
//            }
//        }
//    }
//    
//    init() {
//        self.frame = .zero
//    }
//}
//
//struct GeometryGetter: View {
//    @Binding var rect: CGRect
//    
//    var body: some View {
//        GeometryReader { geometry in
//            AnyView(Color.clear)
//                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
//        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
//            self.rect = value
//        }
//    }
//}
//
//
//struct RectanglePreferenceKey: PreferenceKey {
//    static var defaultValue: CGRect = .zero
//    
//    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
//        value = nextValue()
//    }
//}
