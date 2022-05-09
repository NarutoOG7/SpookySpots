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
        
    var body: some View {
        ZStack {
            locationsCollections
            VStack(spacing: -4) {
                greeting
                    .padding(.bottom, 10)
                HStack {
                    VStack {
                        HStack {
                            SearchBar(type: .exploreByList)
                            mapButton
                        }
                        Divider()
                            .frame(height: 1.5)
                            .background(Color.black)
                            .padding(.top, 12)
                        
                    } .padding()
                }
                Spacer()
            }
        }.padding(.top, 30)
            .onAppear {
                exploreVM.supplyLocationLists()
            }
        
        //        }
    }
    
    
    //MARK: - SubViews
    var greeting: some View {
        HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.title)
                .fontWeight(.ultraLight)
                .padding(.horizontal)
            Text("\(user.name)")
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
        exploreVM.isShowingMap = true
    }
}





struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList()
    }
}

