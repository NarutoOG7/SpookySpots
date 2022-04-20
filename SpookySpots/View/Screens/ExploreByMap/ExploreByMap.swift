//
//  ExploreByMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation

struct ExploreByMap: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    
    let map = MapViewUI()
    
    var body: some View {
        ZStack {
            map
                .ignoresSafeArea()
            VStack {
                HStack {
                    searchAreaButton
                    Spacer()
                    currentLocationButton
                }
                Spacer()
            }
            .padding()
            .offset(y: 60)
            
            VStack {
                HStack {
                    SearchBar(type: .exploreByMap)
                    filterButton
                    listButton
                }
                Spacer()
            }
            .padding()
            
            VStack{
                Spacer()
                locationList
            }
        }
    }
}

//MARK: - Subviews

extension ExploreByMap {

    private var locationsList: AnyView {
        AnyView(
            ScrollViewReader{ scrollView in
        ScrollView(.horizontal) {
            HStack {
                ForEach(locationStore.onMapLocations) { location in
//            LocationPreviewOnMap(location: location)
                    LargeImageLocationView(location: location)
                        .id(location.id)
                }
//                onChange(of: exploreByMapVM.highlightedLocation, perform: { _ in
//                    scrollView.scrollTo(exploreByMapVM.highlightedLocation?.id ?? 0)
//                })
            }
                        } .pagedScrollView()
            }
        )
                
    }

    private var locationList: some View {
        let view: AnyView
        if exploreByMapVM.showingLocationList {
            view = locationsList
        } else {
            view = AnyView(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 200))
        }
        return view
    }
    
    private var searchLocations: some View {
        VStack {
            
            List(exploreByMapVM.searchedLocations) { location in
                NavigationLink {
                    LocationDetails(location: location)
                } label: {
                    Text("\(location.name), \(location.address?.state ?? "")")
                }
                
            }
            .listStyle(.plain)
            .frame(width: 276, height: 300)
            Spacer()
        }.frame(maxHeight: 222)
            .shadow(color: .black, radius: 2, x: 0, y: 0)
        
    }
    
    private var searchResults: some View {
        let view: AnyView
        if exploreByMapVM.searchedLocations.isEmpty {
            view = AnyView(EmptyView())
        } else {
            view = AnyView(searchLocations)
        }
        return view
            .offset(y: 26)
    }
    
    
    //MARK: - Buttons
    
    private var filterButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "slider.vertical.3"),
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: filterButtonPressed)
    }
    
    private var listButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "list.bullet"),
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: listButtonPressed)
    }
    
    private var searchAreaButton: some View {
        Button(action: searchThisArea) {
            Text("Search This Area")
                .background(
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 200, height: 39)
                )
                
                .foregroundColor(.blue)
        }.padding(.leading, 70)
    }
    
    private var currentLocationButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: currentLocationPressed)
    }
    
    //MARK: - Methods
    
    func filterButtonPressed() {
        
    }
    
    func listButtonPressed() {
        exploreByListVM.isShowingMap = false
    }
    
    func searchThisArea() {
        
        GeoFireManager.instance.searchForLocations(region: map.getRegion())
//        FirebaseManager.instance.getLocationDataFromKey(key: "1") { location in
//            print(location.name)
//        }
//        FirebaseManager.instance.showSpotsOnMap(location: CLLocation(latitude: exploreByMapVM.region.center.latitude, longitude: exploreByMapVM.region.center.longitude))
//        FirebaseManager.instance.showSpotsOnMap { locAnnoModel in
//            
//        }
//        FirebaseManager.instance.getLocationsFromSpecificRadius { location in
//            print(location + "_%%%%")
//        }
//        FirebaseManager.instance.getallDocs(
//            center: UserLocationManager.instance.region.center,
//            radius: UserLocationManager.instance.region.distanceMax()) { (location) -> (Void) in
//            locationStore.onMapLocations.append(location)
//            print(locationStore.onMapLocations.count)
//        }
    }
    
    func currentLocationPressed() {
        
    }
    
}



//MARK: - Preview
struct ExploreByMap_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByMap()
            .previewInterfaceOrientation(.portrait)
    }
}
