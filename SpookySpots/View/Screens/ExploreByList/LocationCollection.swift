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
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    
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
    
    //MARK: - Search Locations
    private var searchLocations: some View {
                List(exploreByListVM.searchedLocations, id: \.self.id) { location in
//        List {
        VStack {
//            ForEach(exploreByListVM.searchedLocations) { location in
                NavigationLink("\(location.name), \(location.address?.state ?? "")", destination:  LocationDetails(location: location))
                    .listRowSeparator(.hidden)
            
            }
        }
    }
    
    //MARK: - Trending Locations
    private var trendingLocations: some View {
        ForEach(locationStore.trendingLocations) { location in
            VStack(alignment: .leading) {
                NavigationLink {
                    LocationDetails(location: location)
                } label: {
                    
                    
                    MainLocCell(location: location)
                        .padding(isLastInTrending(location)
                                 ? .horizontal : .leading)
                        .padding(.vertical)
                }
            }
        }
    }
    
    private func isLastInTrending(_ location: Location) -> Bool {
        location.id == locationStore.trendingLocations.last?.id ?? UUID().hashValue
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
                            LocationDetails(location: location)
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
    
    private func isLastInNearbyList(_ location: Location) -> Bool {
        location.id == locationStore.nearbyLocations.last?.id ?? UUID().hashValue
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

