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
        GeometryReader { geo in
            ZStack {
                VStack {
                    greeting
                    mapButton(geo)
                    divider
                    ScrollView(showsIndicators: false) {
                        locationsCollections
                    }
                }
                    searchView(geo)
                
            }
        }
        .onAppear {
            exploreVM.supplyLocationLists()
        }
        .background(K.Images.paperBackground
            .edgesIgnoringSafeArea(.all))
    }
    
    var greeting: some View {
        let nameSizeIsLarge = user.name.count > 10
        return HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.ultraLight)
                .padding(.horizontal)
                .foregroundColor(weenyWitch.brown)
                .lineLimit(1)
            Text("\(user.name)")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.medium)
                .foregroundColor(weenyWitch.orange)
                .lineLimit(1)
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var locationsCollections: some View {
        VStack {
            LocationCollection(collectionType: .nearby)
            LocationCollection(collectionType: .trending)
            LocationCollection(collectionType: .featured)
        }
        .frame(width: UIScreen.main.bounds.width)
        
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1.5)
            .background(weenyWitch.brown)
            .padding(.top, 12)
            .padding(.bottom, -8)
    }
    
    private func searchView(_ geo: GeometryProxy) -> some View {
        VStack {
            SearchBar()
                .padding(.top, geo.size.height / 9.7)
                .padding(.horizontal)
                .padding(.trailing, 65)
            Spacer()
        }
    }
    
    //MARK: - Buttons
    
    private func mapButton(_ geo: GeometryProxy) -> some View {
        return HStack {
            Spacer()
            Spacer()
            CircleButton(size: .small,
                         image: Image(systemName: "map"),
                         mainColor: K.Colors.WeenyWitch.brown,
                         accentColor: K.Colors.WeenyWitch.lightest,
                         clicked: isShowingMap)
        }
//        .padding(.top, geo.size.height / 10)
        .padding(.horizontal)
    }
    
    //MARK: - Methods
    
    func isShowingMap() {
        exploreVM.isShowingMap = true
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList()
    }
}

