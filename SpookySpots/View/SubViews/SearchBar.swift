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
    
    let listRowPadding: Double = 5 // guess
    let listRowMinHeight: Double = 45 // guess
    
    var listRowHeight: Double {
        max(listRowMinHeight, 20 * listRowPadding)
    }
    
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
        List {
        ForEach(0..<exploreVM.searchedLocations.count, id: \.self) { index in
            NavigationLink {
                LD(location: $exploreVM.searchedLocations[index])
            } label: {
                Text(exploreVM.searchedLocations[index].location.name)
            }
            .listRowBackground(Color.clear)
        }
        }
//        .frame(height: CGFloat(exploreVM.searchedLocations.count) * CGFloat(self.listRowHeight))

        .frame(maxHeight: 450)
        .listStyle(.insetGrouped)
        .offset(y: -40)
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
