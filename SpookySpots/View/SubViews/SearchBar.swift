//
//  SearchBar.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct SearchBar: View {
    
    
    //    @State var searchText: String = ""
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    @ObservedObject var locationStore = LocationStore.instance

    var body: some View {
        VStack {
            HStack {
                HStack(spacing: -20) {
                    magGlass
                    searchField
                }
                cancelButton
            }
            if exploreVM.searchText != "" {
                searchResults
            }
        }

        .background(background)
        
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
        }
        
    }
    
    //MARK: - SubViews
    private var magGlass: some View {
        Image(systemName: "magnifyingglass")
            .padding()
            .foregroundColor(K.Colors.WeenyWitch.orange)
    }
    
    private var searchField: some View {
        TextField("Search",
                  text:
                    $exploreVM.searchText)
        .padding()
        .foregroundColor(K.Colors.WeenyWitch.brown)
        .accentColor(K.Colors.WeenyWitch.orange)
        
        
    }
    
    private var searchResults: some View {
        let listHasMoreThanTenItems = exploreVM.searchedLocations.count > 10
        let listHasNoItems = exploreVM.searchedLocations.count == 0
        return List {
        ForEach(0..<exploreVM.searchedLocations.count, id: \.self) { index in
            NavigationLink {
                LD(location: $exploreVM.searchedLocations[index])
            } label: {
                Text(exploreVM.searchedLocations[index].location.name)
            }
            .listRowBackground(Color.clear)
        }
            
        }
        .frame(height: listHasNoItems ? 0 : (listHasMoreThanTenItems ? 450 : (CGFloat(exploreVM.searchedLocations.count) * 45)))
        .listStyle(.inset)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(K.Colors.WeenyWitch.lightest)
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(K.Colors.WeenyWitch.brown))
    }
    
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: cancelSearchTapped) {
            Text("Cancel")
        }
        .opacity(exploreVM.searchText.isEmpty ? 0 : 1)
        .padding()
    }
    
    
    //MARK: - Methods
    private func cancelSearchTapped() {
        DispatchQueue.main.async {
            exploreVM.searchText = ""
            exploreVM.searchedLocations = []
        }
            
    }
}


//MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar()
    }
}
