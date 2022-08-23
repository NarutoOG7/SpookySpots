//
//  LocationCollection.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct LocationCollection: View {
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    @StateObject var locationStore = LocationStore.instance

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
            .foregroundColor(K.Colors.WeenyWitch.brown)
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
                    case .featured:
                        featured
                    }
                }
            })
        }
    }
    
    //MARK: - Search Locations
    private var searchLocations: some View {
        
        ForEach(exploreVM.searchedLocations) { location in
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
    
    //MARK: - Featured
    
    private var featured: some View {
        ForEach(locationStore.featuredLocations) { location in
        VStack(alignment: .leading) {
            NavigationLink {
                LD(location: location)
            } label: {
                
                
                MainLocCell(location: location)
                    .padding(isLastInFeatued(location)
                             ? .horizontal : .leading)
                    .padding(.vertical)
            }
        }
    }
}

private func isLastInFeatued(_ location: LocationModel) -> Bool {
    location.location.id == locationStore.featuredLocations.last?.location.id ?? UUID().hashValue
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
        LocationCollection(collectionType: .featured)
    }
}


//MARK: - Location Collection Types

enum LocationCollectionTypes: String {
    case search = ""
    case nearby = "Nearby Spooks"
    case trending = "Trending"
    case featured = "Featured"
}

