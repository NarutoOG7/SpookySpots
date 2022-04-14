//
//  LocationCollection.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct LocationCollection: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    
    var collectionType: LocationCollectionTypes
    
    var body: some View {
        VStack(alignment: .leading) {
            titleView
            locationsList
        }
        
    }
    
    //MARK: - Subviews
    
    private var titleView: some View {
        Text(collectionType.rawValue)
            .font(.title2)
            .fontWeight(.bold)
            .offset(x: 15, y: 17)
    }
    
    private var locationsList: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack {
                    switch collectionType {
                    case .nearby:
                        if userStore.currentLocation == nil {
                            Text("Need Current Location To Fetch Nearby Locations")
                        } else {
                        ForEach(locationStore.nearbyLocations) { location in
                            VStack(alignment: .leading) {
                                DefaultLocationCell(location: location)
                            }
                        }
                        }
                    case .trending:
                        ForEach(locationStore.trendingLocations) { location in
                            VStack(alignment: .leading) {
                                DefaultLocationCell(location: location)
                            }
                        }
                    case .topRated:
                        ForEach(locationStore.locations) { location in
                            VStack(alignment: .leading) {
                                DefaultLocationCell(location: location)
                            }
                        }
                    }
                }
            })
        }
    }
}

struct LocationCollection_Previews: PreviewProvider {
    static var previews: some View {
        LocationCollection(collectionType: .nearby)
    }
}


//MARK: - Location Collection Types

enum LocationCollectionTypes: String {
    case nearby = "Nearby Spooks"
    case trending = "Trending"
    case topRated = "Top Rated"
}

