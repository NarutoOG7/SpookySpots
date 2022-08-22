//
//  LargeImageLocationView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LargeImageLocationView: View {
    
    var location: LocationModel
    
    @State private var imageURL = URL(string: "")
    
    @EnvironmentObject var favoritesLogic: FavoritesLogic
    
    var body: some View {
        ZStack {
            image
            favoriteButton
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        title
                        address
                    }
                    Spacer()
//                    }
//                    priceTag
                }.padding(10).background(background)

            }
            
        }.cornerRadius(25).frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
        
            .onAppear {
                loadImageFromFirebase()
            }
        
    }
    
    //MARK: - SubViews
    private var image: some View {
        WebImage(url: self.imageURL)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
//            .padding(.bottom)
        
    }
    
    
    private var title: some View {
        Text(location.location.name)
            .font(.headline)
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(Color.white)
            .padding(.horizontal)
    }
    
    private var address: some View {
        Text(location.location.address?.streetCityState() ?? "")
            .font(.footnote)
            .foregroundColor(Color(white: 1, opacity: 0.7))
            .lineLimit(1)
            .padding(.horizontal)
    }
    
//    private var price: some View {
//        let txt: Text
//        if let price = location.location.price {
//           if price != 0 {
//               txt = Text(String(format: "$%.0f", price))
//           } else {
//               txt = Text("")
//           }
//        } else {
//            txt = Text("")
//        }
//        return txt
//            .font(.title2)
//            .foregroundColor(Color(red: 18/255, green: 203/255, blue: 196/255))
//            .multilineTextAlignment(.trailing)
//    }
    
//    private var priceTag: some View {
//        VStack(alignment: .trailing, spacing: -5) {
//            price
//            Text("/night")
//                .font(.footnote)
//                .fontWeight(.light)
//                .foregroundColor(Color(red: 18/255, green: 203/255, blue: 196/255))
//        }
//        .padding(.trailing)
//    }
    
    private var background: some View {
        Rectangle()
            .fill()
    }
    
    //MARK: - Buttons
    private var favoriteButton: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: favoritesTapped) {
                    Image(systemName: favoritesLogic.contains(location) ? "heart.fill" : "heart")
                        .renderingMode(.none)
                        .resizable()
                        .shadow(color: Color.black, radius: 1.5)
                        .tint(Color.red)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                }
                    Spacer()
            }
        }.padding()
    }
    
    //MARK: - Methods
    
    private func loadImageFromFirebase()  {
        if let imageString = location.location.imageName {
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                self.imageURL = url
            }
        }
    }
    
    private func favoritesTapped() {
        if favoritesLogic.contains(location) {
            favoritesLogic.removeHotel(location)
        } else {
            favoritesLogic.addHotel(location)
        }
    }
}


//MARK: - Preview
struct LargeImageLocationView_Previews: PreviewProvider {
    static var previews: some View {
        LargeImageLocationView(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}
