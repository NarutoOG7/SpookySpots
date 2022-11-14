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
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
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

                }.padding(10).background(background)

            }
            
        }.cornerRadius(25).frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
        
            .onAppear {
                loadImageFromFirebase()
            }
        
    }
    
    //MARK: - SubViews

    private var image: some View {
        AsyncImage(url: self.imageURL) { image in
            image
                .resizable()
                .aspectRatio(0.9, contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
                .cornerRadius(15)
                .shadow(color: .black, radius: 3, x: 0, y: 1.5)
        } placeholder: {
            ProgressView()
        }
    }
    
    
    private var title: some View {
        Text(location.location.name)
            .font(.headline)
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(weenyWitch.lightest)
            .padding(.horizontal)
    }
    
    private var address: some View {
        Text(location.location.address?.streetCityState() ?? "")
            .font(.footnote)
            .foregroundColor(weenyWitch.light)
            .lineLimit(1)
            .padding(.horizontal)
    }
    
    private var background: some View {
        Rectangle()
            .fill(weenyWitch.black)
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
