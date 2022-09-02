//
//  Favorites.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct Favorites: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
    var body: some View {
        ZStack {
            K.Colors.WeenyWitch.black
            locationsList
        }
        .navigationBarTitleDisplayMode(.inline)

    }
    
    var locationsList: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(0..<locationStore.favoriteLocations.count, id: \.self) { index in
                    NavigationLink {
                        LD(location: $locationStore.favoriteLocations[index])
                    } label: {
                        
                        FavoritesCell(location: locationStore.favoriteLocations[index])
//                    }
                    }.padding(.top, 8)
                    

                }
                
            }
            
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites()
    }
}
