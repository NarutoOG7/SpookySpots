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
    
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
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
    }
    
    private var searchField: some View {
        TextField("Search",
                  text:
                    typeIsList() ?
                    $exploreByListVM.searchText
                  :
                    $exploreByMapVM.searchText)
            .padding()
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.red)
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black))
    }
    
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: cancelSearchTapped) {
            Text("Cancel")
        }
        .opacity(typeIsList() ?
                    (exploreByListVM.searchText.isEmpty ? 0 : 1)
                 :
                    (exploreByMapVM.searchText.isEmpty ? 0 : 1))
            .padding()
    }
    
    
    //MARK: - Methods
    private func cancelSearchTapped() {
        switch type {
        case .exploreByMap:
            exploreByMapVM.searchText = ""
            exploreByMapVM.searchedLocations = []
        case .exploreByList:
            exploreByListVM.searchText = ""
            exploreByListVM.searchedLocations = []
            
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
