//
//  SearchBar.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct SearchBar: View {
    
    
//    @State var searchText: String = ""
    var type: SearchFromType
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    @ObservedObject var locationStore = LocationStore.instance
    
    var body: some View {
        
        HStack {
            HStack(spacing: -20) {
            magGlass
            searchField
            }
            cancelButton
        }
        .background(background)
        
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
                    typeIsList() ?
                    $exploreVM.searchText
                  :
                    $exploreVM.searchText)
            .padding()
            .foregroundColor(K.Colors.WeenyWitch.brown)
            .accentColor(K.Colors.WeenyWitch.orange)
            

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
        .opacity(typeIsList() ?
                    (exploreVM.searchText.isEmpty ? 0 : 1)
                 :
                    (exploreVM.searchText.isEmpty ? 0 : 1))
            .padding()
    }
    
    
    //MARK: - Methods
    private func cancelSearchTapped() {
        switch type {
        case .exploreByMap:
            exploreVM.searchText = ""
            exploreVM.searchedLocations = []
        case .exploreByList:
            exploreVM.searchText = ""
            exploreVM.searchedLocations = []
            
        }
    }
    
    private func typeIsList() -> Bool {
        type == .exploreByList
    }

    
    //MARK: - SearchFromType
    enum SearchFromType {
        case exploreByList
        case exploreByMap
    }
}


//MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(type: .exploreByList)
    }
}
