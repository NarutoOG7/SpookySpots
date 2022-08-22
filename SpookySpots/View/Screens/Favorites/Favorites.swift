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

//            .padding()
//            .background(Image(K.Images.paperBackground).opacity(0.5))
//
        
    }
    
    var locationsList: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(locationStore.favoriteLocations) { location in
                    NavigationLink {
                        LD(location: location)
                    } label: {
                        FavoritesCell(location: location)
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
