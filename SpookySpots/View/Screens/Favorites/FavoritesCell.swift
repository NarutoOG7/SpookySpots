//
//  FavoritesCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/16/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoritesCell: View {
    
    var location: LocationModel
    
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        
        let screenSize = UIScreen.main.bounds.size
        
        ZStack {
            image
            title
        }
        .frame(width: screenSize.width - 20, height: screenSize.height / 3)
        
        .onAppear {
            loadImageFromFirebase()
        }
        
    }
    
    private var image: some View {
        WebImage(url: self.imageURL)
            .resizable()
            .cornerRadius(15)
            .shadow(color: .black, radius: 3, x: 0, y: 1.5)
    }
    
    private var title: some View {
        VStack {
            Spacer()
            Text(location.location.name)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(Color.white)
                .shadow(color: .black, radius: 1, x: 0, y: 2)
                .padding(10)
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

struct FavoritesCell_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesCell(location: LocationModel.example)
    }
}
