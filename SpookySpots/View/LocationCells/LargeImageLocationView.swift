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
        VStack(alignment: .leading) {
            image
            HStack {
                VStack(alignment: .leading) {
                    title
                    address
                }
            }
        }.cornerRadius(25).padding(.bottom).background(background)

    }
    
    
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
            .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/4)
            .padding(.bottom)
    }
    
    
    private var title: some View {
        Text(location.name)
            .font(.title3)
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(Color(red: 18/255, green: 203/255, blue: 196/255))
            .padding(.horizontal)
    }
    
    private var address: some View {
        Text(location.address?.streetCityState() ?? "")
            .font(.subheadline)
            .foregroundColor(Color(red: 153/255, green: 128/255, blue: 250/255))
            .lineLimit(1)
            .padding(.horizontal)
    }
    
    private var priceTag: some View {
        Text(String(format: "$%.0f", location.price ?? 0))
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill()
    }
    //MARK: - Buttons
    
    //MARK: - Methods
}


//MARK: - Preview
struct LargeImageLocationView_Previews: PreviewProvider {
    static var previews: some View {
        LargeImageLocationView(location: Location.example)
    }
}
