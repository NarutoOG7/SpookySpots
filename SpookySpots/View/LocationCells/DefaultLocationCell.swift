//
//  DefaultLocationCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct DefaultLocationCell: View {
    @State var location: Location
    
    var body: some View {
        VStack(alignment: .leading) {
                mainImage
                HStack {
                title
                    Spacer()
                    favoriteButton
                }
                address
                
            }
        .frame(width: 300, height: 280)
    }
    
    //MARK: - SubViews
    
    private var mainImage: some View {
        VStack {
        if let image = location.baseImage {
        image
            .resizable()
            .frame(width: 300, height: 160)
        } else {
            Image("bannack")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 160)
        }
        }
        .cornerRadius(10)
    }
    
    private var title: some View {
        Text(location.name)
            .font(.title2)
            .fontWeight(.medium)

    }
    
    private var address: some View {
        Text(location.address?.streetCity() ?? "")

    }
    
    //MARK: - Buttons
    private var favoriteButton: some View {
        Button(action: favoriteTapped) {
            Image(systemName: "heart")
                .resizable()
                .frame(width: 15, height: 15)
        }
        .padding(.trailing, 7)
    }
    
    //MARK: - Methods
    
    func favoriteTapped() {
       
    }
}

struct DefaultLocationCell_Previews: PreviewProvider {
    static var previews: some View {
        DefaultLocationCell(location: Location.example)
    }
}
