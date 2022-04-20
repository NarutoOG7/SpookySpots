//
//  TabBarSetup.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct TabBarSetup: View {
    
    @State private var selection = 0
    
    
    init() {
        TripPageVM.instance.initTrip()
    }
    
    var body: some View {
        TabView(selection: $selection) {
            exploreTab
            tripTab
            settingsTab
        }
    }
    
    private var exploreTab: some View {
            ExploreByList()
            .tabItem {
                Text("Explore")
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(0)
    }
    
    private var favoritesTab: some View {
        Favorites()
            .tabItem {
                Text("Favorites")
                Image(systemName: "heart")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(1)
    }
    
    
    private var tripTab: some View {
        TripScreen()
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
        SettingsPage()
            .tabItem {
                Text("Settings")
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .tag(3)
    }
    

}

struct TabBarSetup_Previews: PreviewProvider {
    static var previews: some View {
        TabBarSetup()
    }
}
