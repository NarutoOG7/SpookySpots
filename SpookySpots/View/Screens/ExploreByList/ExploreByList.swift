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
            searchView
            
        }
        .onAppear {
            exploreVM.supplyLocationLists()
        }
        .background(K.Images.paperBackground
            .edgesIgnoringSafeArea(.all))
    }
    
    var greeting: some View {
        HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.title)
                .fontWeight(.ultraLight)
                .padding(.horizontal)
                .foregroundColor(weenyWitch.brown)
            Text("\(user.name)")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(weenyWitch.orange)
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
    
    private var searchView: some View {
        VStack {
            SearchBar()
                .padding(.top, 70)
                .padding(.horizontal)
                .padding(.trailing, 65)
            Spacer()
        }
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
    
    func isShowingMap() {
        exploreVM.isShowingMap = true
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList()
    }
}

