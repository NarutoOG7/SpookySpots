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
    
//    @Binding var locations: [LocationModel]
//    var title: String
    
    @State var nearbyLocations = [LocationModel]()
    @State var trendingLocations = [LocationModel]()
    @State var featuredLocations = [LocationModel]()

    @EnvironmentObject var locationStore: LocationStore
//    @ObservedObject var locationStore = LocationStore.instance
    
    @State var passingLocation: LocationModel?

    var collectionType: LocationCollectionTypes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            titleView
//            list
            locationsList
        }
//        .onAppear {
//            self.nearbyLocations = locationStore.nearbyLocations
//            self.trendingLocations = locationStore.trendingLocations
//            self.featuredLocations = locationStore.featuredLocations
//        }
    }
    
    //MARK: - Subviews
    
    private var titleView: some View {
        Text(collectionType.rawValue)
//        Text(title)
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
                        searchLocationsView
                    case .nearby:
                        nearbyLocationsView
                    case .trending:
                        trendingLocationsView
                    case .featured:
                        featuredList
                    }
                }
            })
        }
    }
//    private var list: some View {
//        HStack {
//            ForEach(locations) { location in
//                NavigationLink {
//                    LD(location: location)
//                } label: {
//                    MainLocCell(location: location)
//                        .padding(isLastInTrending(location)
//                                 ? .horizontal : .leading)
//                        .padding(.vertical)
//                }
//            }
//        }
//    }
//    private func isLastInList(_ location: LocationModel) -> Bool {
//        location.location.id == locations.last?.location.id ?? UUID().hashValue
//    }
//
    //MARK: - Search Locations
    private var searchLocationsView: some View {

        ForEach(0..<locationStore.hauntedHotels.filter({ exploreVM.searchText.isEmpty ? true : $0.location.name.localizedCaseInsensitiveContains(exploreVM.searchText)
        }).count, id: \.self) { index in
//        ForEach(0..<exploreVM.searchedLocations.filter({ exploreVM.searchText.isEmpty ? true : $0.location.name.localizedCaseInsensitiveContains(exploreVM.searchText) }).count, id: \.self) { index in
            NavigationLink {
                LD(location: $locationStore.hauntedHotels[index])
            } label: {
                MainLocCell(location: locationStore.hauntedHotels[index])
            }
        }
    }
    
    //MARK: - Trending Locations
    private var trendingLocationsView: some View {
        ForEach(0..<locationStore.trendingLocations.count, id: \.self) { index in
//        ForEach(trendingLocations) { location in
            VStack(alignment: .leading) {
                NavigationLink {
                    LD(location: $locationStore.trendingLocations[index])
                    
                } label: {
                    let location = locationStore.trendingLocations[index]
                    
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
    
    private var featuredList: some View {
        ForEach(0..<locationStore.featuredLocations.count, id: \.self) { index in
//        ForEach(locationStore.featuredLocations, id: \.id) { location in
//        ForEach(featuredLocations, id: \.id) { location in
        VStack(alignment: .leading) {
            NavigationLink {
                LD(location: $locationStore.featuredLocations[index])
            } label: {
                
                let location = locationStore.featuredLocations[index]
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
    private var nearbyLocationsView: some View {
        let view: AnyView
        if userStore.currentLocation == nil {
            view = AnyView(Text("Need Current Location").fontWeight(.light).padding())
        } else {
            view = AnyView(
//                ForEach(locationStore.nearbyLocations, id: \.id) { location in

                ForEach(0..<locationStore.nearbyLocations.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            LD(location: $locationStore.nearbyLocations[index])
                        } label: {
                            let location = locationStore.nearbyLocations[index]
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
    static let locationStore = LocationStore()
    static var previews: some View {
//        LocationCollection(locations: [], title: "")
//        LocationCollection(locations: .constant([]), title: "Nearby")
        LocationCollection(collectionType: .featured)
            .environmentObject(locationStore)
    }
}


//MARK: - Location Collection Types

enum LocationCollectionTypes: String {
    case search = ""
    case nearby = "Nearby Spooks"
    case trending = "Trending"
    case featured = "Featured"
}

