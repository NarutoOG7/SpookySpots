//
//  LargeImageLocationView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import SwiftUI

struct LargeImageLocationView: View {
    var location: Location
    
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
                    priceTag
                }.padding(10).background(background)
            }
            
        }.cornerRadius(25).frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2.7)
        
    }
    
//    var body: some View {
//        VStack(alignment: .leading) {
//            ZStack {
//                image
//                favoriteButton
//            }
//            HStack {
//                VStack(alignment: .leading) {
//                    title
//                    address
//                }
//                Spacer()
//                priceTag
//            }
//        }.cornerRadius(25).padding(.bottom).background(background)
//            .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2.7)
//    }
    
    
    //MARK: - SubViews
    private var image: some View {
        let img: Image
        if let image = location.baseImage {
            img = image
        } else {
            img = Image("bannack")
        }
        return img
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2.7)
//            .padding(.bottom)
    }
    
    
    private var title: some View {
        Text(location.name)
            .font(.headline)
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(Color.white)
            .padding(.horizontal)
    }
    
    private var address: some View {
        Text(location.address?.streetCityState() ?? "")
            .font(.footnote)
            .foregroundColor(Color(white: 1, opacity: 0.7))
            .lineLimit(1)
            .padding(.horizontal)
    }
    
    private var priceTag: some View {
        Text(String(format: "$%.0f", location.price ?? 0))
            .foregroundColor(Color(red: 18/255, green: 203/255, blue: 196/255))
            .padding(.trailing)
    }
    
    private var background: some View {
        Rectangle()
            .fill()
    }
    
    //MARK: - Buttons
    private var favoriteButton: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "heart")
                    .renderingMode(.none)
                    .resizable()
                    .shadow(color: Color.black, radius: 1.5)
                    .tint(Color.red)
                    .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)
                Spacer()
            }
        }.padding()
    }
    
    //MARK: - Methods
}


//MARK: - Preview
struct LargeImageLocationView_Previews: PreviewProvider {
    static var previews: some View {
        LargeImageLocationView(location: Location.example)
    }
}
