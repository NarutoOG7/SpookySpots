//
//  Favorites.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct Favorites: View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
        
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            K.Colors.WeenyWitch.black
            if locationStore.favoriteLocations.count == 0 {
                emptyLocationsView
            } else {
                locationsList
            }
        }
        .navigationBarTitleDisplayMode(.inline)

    }
    
    var emptyLocationsView: some View {
        Text("Start exploring and track your favorites here!")
            .foregroundColor(weenyWitch.orange)
            .font(.avenirNext(size: 22))
    }
    
    var locationsList: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(0..<locationStore.favoriteLocations.count, id: \.self) { index in
                    
                    NavigationLink {
                        LD(location: $locationStore.favoriteLocations[index],
                           userStore: userStore,
                           firebaseManager: firebaseManager,
                           errorManager: errorManager)
                    } label: {
                        FavoritesCell(location: locationStore.favoriteLocations[index])
                    }.padding(.top, 8)
                }
                
            }
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites(locationStore: LocationStore(),
                  userStore: UserStore(),
                  firebaseManager: FirebaseManager(),
                  errorManager: ErrorManager())
    }
}
