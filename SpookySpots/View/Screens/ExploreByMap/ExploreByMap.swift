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
    
    var body: some View {
        ZStack {
            map
            VStack {
                HStack {
                    VStack {
                        HStack {
                            SearchBar()
                            filterButton
                        }
                        Rectangle().fill(Color.clear).frame(width: 100, height: 50)
                    }
                    VStack {
                    listButton
                        currentLocationButton

                    }
                }.padding(.horizontal)
                Spacer()
                
            }
            
            VStack {
                Spacer()
                locationList
            }
            
        
        }
    }
}

//MARK: - Subviews

extension ExploreByMap {
    
    private var map: some View {
        MapView()
//        MapForExplore()
    }

    private var locationsList: AnyView {
        AnyView(
        ScrollView(.horizontal) {
            HStack {
                ForEach(locationStore.onMapLocations) { location in
//            LocationPreviewOnMap(location: location)
                    LargeImageLocationView(location: location)

                }

            }
    } .pagedScrollView()
        
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
        }
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
    }
}
