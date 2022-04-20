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
        VStack(alignment: .leading) {
            title
            
            locationsList
        }
    }
    
    var title: some View {
        Text("Favorite Spots")
            .font(.title)
            .fontWeight(.thin)
            .padding()
    }
    
    var locationsList: some View {
        List(locationStore.tripLocationsExample) { location in
            DefaultLocationCell(location: location)
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites()
    }
}
