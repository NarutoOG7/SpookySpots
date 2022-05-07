//
//  TabBarSetup.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct TabBarSetup: View {
    
    @State private var selection = 0
    @StateObject var favoritesLogic = FavoritesLogic()
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    init() {
        TripPageVM.instance.initTrip()
    }
    
    var body: some View {
//        NavigationView {
        TabView(selection: $selection) {
            exploreTab
            favoritesTab
            tripTab
            settingsTab
        }
        .environmentObject(favoritesLogic)
//        }
    }
    
    private var exploreTab: some View {
        NavigationView {
            
            exploreHelperView

                .navigationTitle("Explore")
        }
        .background(Color.clear)
        
            .tabItem {
                Text("Explore")
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(0)
        
    }
    
    private var favoritesTab: some View {
        NavigationView {
            Favorites()
                .navigationTitle("Favorites")
        }
            .tabItem {
                Text("Favorites")
                Image(systemName: "heart")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(1)
    }
    
    
    private var tripTab: some View {
        NavigationView {
            TripScreen()
                .navigationTitle("Trip")
        }
            .tabItem {
                VStack {
                    Image(systemName: "car.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("Trip")
                }
            }
            .tag(2)
    }
    

    private var settingsTab: some View {
        NavigationView {
            SettingsPage()
                .navigationTitle("Settings")
        }
            .tabItem {
                Text("Settings")
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(3)
    }
    
    
    private var exploreHelperView: some View {
        let view: AnyView
        if exploreVM.isShowingMap {
            view = AnyView(ExploreByMap())
        } else {
            view = AnyView(ExploreByList())
        }
        return view
    }
}

struct TabBarSetup_Previews: PreviewProvider {
    static var previews: some View {
        TabBarSetup()
    }
}
