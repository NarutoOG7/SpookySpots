//
//  ExploreByList.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI


struct ExploreByList: View {
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var locationStore = LocationStore.instance
//    @ObservedObject var locationManager = UserLocationManager.instance
    
//    init() {
//        exploreByListVM.supplyNearbyLocations()
//    }
    
    var body: some View {
        if exploreByListVM.isShowingMap {
//            VStack {
//                Spacer(minLength: 45)
                ExploreByMap()
//            }
        } else {
//            NavigationView {
                VStack(alignment: .leading) {

                    greeting
                    HStack(spacing: 9) {
                        SearchBar()
                        Spacer()
                        filterButton
                        mapButton
                    }
                    
                    Spacer(minLength: 20)
                    Divider()
                        .frame(height: 1.5)
                        .background(Color.black)
                    
                    
                    locationsCollections
//                        list
                    
                    Spacer()
                }
                .padding()
            
                .onAppear {
                    exploreByListVM.supplyLocationLists()
                }
//            }
//            .navigationBarHidden(true)
        }
            
    }
    
    //MARK: - SubViews
    var greeting: some View {
        Text("Good Evening, \(userStore.user.name)")
            .font(.largeTitle)
            .fontWeight(.bold)
        
    }
    
    private var list: some View {
        List(locationStore.nearbyLocations) { location in
            Text(location.name)
        }
    }
    
    private var locationsCollections: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 2) {
//                    LocationCollection(collectionType: .topRated)
                    LocationCollection(collectionType: .nearby)
                    LocationCollection(collectionType: .trending)
                }
            })
            .frame(width: UIScreen.main.bounds.width)
            .padding(.trailing, -40.0)
        }
        .offset(x: -15, y: 15)
    }
    
    
    
    //MARK: - Buttons
    private var filterButton: some View {
        CircleButton(size: .small, image: Image(systemName: "slider.vertical.3"), outlineColor: .black, iconColor: .black, backgroundColor: .white, clicked: filterButtonTapped)
    }
    
    private var mapButton: some View {
        CircleButton(size: .small, image: Image(systemName: "map"), outlineColor: .black, iconColor: .black, backgroundColor: .white, clicked: isShowingMap)
    }
    
    //MARK: - Methods
    func filterButtonTapped() {
        
    }
    
    func isShowingMap() {
        exploreByListVM.isShowingMap = true
    }
}





struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList()
    }
}

