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
    @State var searchText = ""
    @State var showingSearchResults = false
    
    var body: some View {
//        if exploreByListVM.isShowingMap {
//            //            VStack {
//            //                Spacer(minLength: 45)
//            ExploreByMap()
//            //            }
//        } else {
//
                ZStack {
                    locationsCollections
                    VStack(spacing: -4) {
                        greeting
                            .padding(.bottom, 10)
                        HStack {
                            VStack {
                                HStack {
                                    SearchBar(type: .exploreByList)
//                                    filterButton
                                    mapButton
                                }
                                Divider()
                                    .frame(height: 1.5)
                                    .background(Color.black)
                                    .padding(.top, 12)
                                
                                HStack {
                                    searchResults
                                    Spacer()
                                }
                            } .padding()
                        }
                        Spacer()
                    }
                }.padding(.top, 30)
                    .navigationBarHidden(true)
                    .onAppear {
                        exploreByListVM.supplyLocationLists()
                    }
            
//        }
    }
    
    
    //MARK: - SubViews
    var greeting: some View {
        HStack(spacing: -7) {
            Text("\(exploreByListVM.greetingLogic()),")
                .font(.title)
                .fontWeight(.ultraLight)
                .padding(.horizontal)
            Text("\(userStore.user.name)")
                .font(.title)
                .fontWeight(.medium)
            Spacer()
        }
    }
    
    private var locationsCollections: some View {
        VStack {
            
            Spacer(minLength: 130)
            VStack {
                ScrollView(.vertical, showsIndicators: false, content: {
//                    VStack {
                    VStack(spacing: -14) {
                        LocationCollection(collectionType: .search)
                        LocationCollection(collectionType: .nearby)
                        LocationCollection(collectionType: .trending)
                    }
                })
                .frame(width: UIScreen.main.bounds.width)
                
            }
        }
    }
    
    private var searchLocations: some View {
        VStack {
            
            List(exploreByListVM.searchedLocations) { location in
                NavigationLink {
                    LocationDetails(location: location)
                } label: {
                    Text("\(location.location.name), \(location.location.address?.state ?? "")")
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
        if exploreByListVM.searchedLocations.isEmpty {
            view = AnyView(EmptyView())
        } else {
            view = AnyView(searchLocations)
        }
        return view
            .offset(x: 2, y: 4)
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

