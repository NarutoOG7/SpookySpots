//
//  LocationCollection.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct LocationCollection: View {
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    
    @ObservedObject var locationStore = LocationStore.instance
    
    var collectionType: LocationCollectionTypes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                    case .search:
                        searchLocations
                    case .nearby:
                        nearbyLocations
                    case .trending:
                        trendingLocations
                    case .topRated:
                        topRated
                    }
                }
            })
        }
    }
    
    //MARK: - Search Locations
    private var searchLocations: some View {
        
        ForEach(exploreByListVM.searchedLocations) { location in
            NavigationLink {
                LD(location: location)
            } label: {
                MainLocCell(location: location)
            }
        }
    }
    
    //MARK: - Trending Locations
    private var trendingLocations: some View {
        ForEach(locationStore.trendingLocations) { location in
            VStack(alignment: .leading) {
                NavigationLink {
//                    LocationDetails(location: location)
                    LD(location: location)
                } label: {
                    
                    
                    MainLocCell(location: location)
                        .padding(isLastInTrending(location)
                                 ? .horizontal : .leading)
                        .padding(.vertical)
                }
            }
        }
    }
    
    private func isLastInTrending(_ location: LocationModel) -> Bool {
        location.location.id == locationStore.trendingLocations.last?.location.id ?? UUID().hashValue
    }
    
    //MARK: - TopRated
    
    private var topRated: some View {
        Text("Top Rated")
    }
    
    
    //MARK: - Nearby Locations
    private var nearbyLocations: some View {
        let view: AnyView
        if userStore.currentLocation == nil {
            view = AnyView(Text("Need Current Location").fontWeight(.light).padding())
        } else {
            view = AnyView(
                ForEach(locationStore.nearbyLocations) { location in

                    VStack(alignment: .leading) {
                        NavigationLink {
                            LD(location: location)
                        } label: {
                            MainLocCell(location: location)
                                .padding(isLastInNearbyList(location)
                                         ? .horizontal : .leading)
                                .padding(.vertical)
                        }
                    }
                })
        }
        return view
    }
    
    private func isLastInNearbyList(_ location: LocationModel) -> Bool {
        location.location.id == locationStore.nearbyLocations.last?.location.id ?? UUID().hashValue
    }
}

struct LocationCollection_Previews: PreviewProvider {
    static var previews: some View {
        LocationCollection(collectionType: .nearby)
    }
}


//MARK: - Location Collection Types

enum LocationCollectionTypes: String {
    case search = ""
    case nearby = "Nearby Spooks"
    case trending = "Trending"
    case topRated = "Top Rated"
}

