//
//  ExploreByList.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI


struct ExploreByList: View {
    
    @State var searchText = ""
    @State var showingSearchResults = false
    @State var user = UserStore.instance.user
    
    @ObservedObject private var exploreVM = ExploreViewModel.instance
    @ObservedObject private var tripLogic = TripLogic.instance
    @ObservedObject private var locationStore = LocationStore.instance
    
    @Environment(\.managedObjectContext) var moc
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            VStack {
                greeting
                mapButton
                divider
                ScrollView(showsIndicators: false) {
                    locationsCollections
                }
            }
            VStack {
                SearchBar()
                    .padding(.top, 70)
                    .padding(.horizontal)
                    .padding(.trailing, 65)
                Spacer()
            }
        
        }
        .onAppear {
            exploreVM.supplyLocationLists()
        }
        .background(K.Images.paperBackground.opacity(0.5))
    }
//
//    var body: some View {
//        ZStack {
//            locationsCollections
//            VStack(spacing: -4) {
//                greeting
//                    .padding(.bottom, 10)
//                HStack {
//                    VStack {
//                        HStack {
//                            SearchBar(type: .exploreByList)
//                            mapButton
//                        }
//divider
//
//                    } .padding()
//                }
//                Spacer()
//            }
//        }.padding(.top, 30)
//            .onAppear {
//                exploreVM.supplyLocationLists()
////                self.tripLogic.setUp(self.moc)
//            }
//
//        //        }
//            .background(Image(K.Images.paperBackground).opacity(0.5))
//
//    }
//
    
    //MARK: - SubViews
    var greeting: some View {
        HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.title)
                .fontWeight(.ultraLight)
//                .fontWeight(.light)
                .padding(.horizontal)
                .foregroundColor(K.Colors.WeenyWitch.brown)
            Text("\(user.name)")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(K.Colors.WeenyWitch.orange)
            Spacer()
        }
        .padding(.top, 20)
//        .padding(.bottom, )
    }
    
    private var locationsCollections: some View {
        VStack {
            
//            Spacer(minLength: 130)
//            VStack {
//                ScrollView(.vertical, showsIndicators: false, content: {
//
//                    VStack(spacing: -14) {
//                        LocationCollection(locations: $locationStore.nearbyLocations, title: "Nearby Spooks")
//                        LocationCollection(locations: $locationStore.trendingLocations, title: "Trending")
//                        LocationCollection(locations: $locationStore.featuredLocations, title: "Featured")
                        
//                        LocationCollection(collectionType: .search)
                        LocationCollection(collectionType: .nearby)
                        LocationCollection(collectionType: .trending)
                        LocationCollection(collectionType: .featured)
                    }
//                })
                .frame(width: UIScreen.main.bounds.width)
                
//            }
//        }
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1.5)
            .background(K.Colors.WeenyWitch.brown)
            .padding(.top, 12)
            .padding(.bottom, -8)
    }
    
    //MARK: - Buttons
    
    private var mapButton: some View {
        HStack {
            Spacer()
            Spacer()
        CircleButton(size: .small,
                     image: Image(systemName: "map"),
                     mainColor: K.Colors.WeenyWitch.brown,
                     accentColor: K.Colors.WeenyWitch.lightest,
                     clicked: isShowingMap)
        }
        .padding(.horizontal)
    }
    
    //MARK: - Methods
    func filterButtonTapped() {
        
    }
    
    func isShowingMap() {
        exploreVM.isShowingMap = true
    }
}





struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList()
    }
}

