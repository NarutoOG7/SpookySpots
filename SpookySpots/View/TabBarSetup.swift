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
    @StateObject var tripLogic = TripLogic.instance
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    init() {
        let appearance =  UITabBar.appearance()
       appearance.barTintColor = UIColor(K.Colors.WeenyWitch.brown)
        appearance.unselectedItemTintColor = UIColor(K.Colors.WeenyWitch.light)
      }
    
    var body: some View {
//        NavigationView {
        TabView(selection: $selection) {
            exploreTab
            favoritesTab
            tripTab
            settingsTab
        }
        .accentColor(K.Colors.WeenyWitch.orange)
        .tint(Color("WeenyWitch/ColorThree"))
        .environmentObject(favoritesLogic)
        .environmentObject(tripLogic)
        
//        }
    }
    
    private var exploreTab: some View {
        NavigationView {
            
            exploreHelperView

                .navigationTitle("Explore")
                .navigationBarHidden(true)
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
            TripPage()
                .navigationTitle("Trip")
                .navigationBarHidden(true)
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
