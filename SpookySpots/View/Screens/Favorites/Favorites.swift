//
//  Favorites.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct Favorites: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    
    var body: some View {
            locationsList
        
    }
    
    var locationsList: some View {
        List(locationStore.favoriteLocations) { location in
            DefaultLocationCell(location: location)
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites()
    }
}
