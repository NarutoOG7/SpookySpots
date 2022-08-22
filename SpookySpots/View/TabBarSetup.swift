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
        

        let tabBarAppearance =  UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(K.Colors.WeenyWitch.black)
        tabBarAppearance.unselectedItemTintColor = UIColor(K.Colors.WeenyWitch.light)
        
        ///This background color is to maintain the same color on scrolling.
        tabBarAppearance.backgroundColor = UIColor(K.Colors.WeenyWitch.black).withAlphaComponent(0.92)
        tabBarAppearance.tintColor = UIColor(K.Colors.WeenyWitch.orange)
        
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor = 
            UIColor( K.Colors.WeenyWitch.orange)
                .withAlphaComponent(0.94)
            
            appearance.titleTextAttributes =
            [.foregroundColor : UIColor(K.Colors.WeenyWitch.brown)]
            
            appearance.largeTitleTextAttributes =
            [.foregroundColor : UIColor(K.Colors.WeenyWitch.black)]
            
            appearance.shadowColor = .clear
            appearance.backButtonAppearance.normal.titleTextAttributes =
            [.foregroundColor : UIColor(K.Colors.WeenyWitch.brown)]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
        }


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
        .accentColor(K.Colors.WeenyWitch.black)
        
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
        .accentColor(K.Colors.WeenyWitch.black)
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
        .accentColor(K.Colors.WeenyWitch.black)
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
        .accentColor(K.Colors.WeenyWitch.black)
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
