//
//  DatabaseView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import SwiftUI

struct DatabaseView: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    
    @State var failedLocations: [Location] = []
    
    @State var showingMoreAllLocations = false
    @State var showingMoreFailedLocations = false
    
    var body: some View {
        VStack {
            ScrollView {
                allLocationsView
                failedLocationsView
                createGeoFireCoordsButton
            }
        }
        .navigationTitle("Database")
    }
    
    //MARK: - All Locations View
    
    var allLocationsView: some View {
        VStack {
            HStack {
                Text("All Locations")
                    .font(.title2)
                    .fontWeight(.thin)
                Spacer()
                allLocationsButton
            }.padding()
            Divider()
            allLocationsList
        }.padding(.vertical)
    }
    
    var allLocationsList: some View {
        VStack(alignment: .leading) {
            ForEach(locationStore.hauntedHotels.prefix(self.showingMoreAllLocations ? .max : 4)) { location in
                Text("\(location.id): \(location.name)")
            }.padding(3)
        }
    }
    

    
    //MARK: - Failed Locations View
    
    var failedLocationsView: some View {
        VStack {
            HStack {
                Text("Failed Locations")
                    .font(.title2)
                    .fontWeight(.thin)
                Spacer()
                failedLocationsButton
            }.padding()
            Divider()
            failedLocationsList
        }.padding(.vertical)
    }
    
    var failedLocationsList: some View {
        List(failedLocations) { location in
            Text("\(location.id), \(location.name)")
        }
        .lineLimit(self.showingMoreFailedLocations ? .none : 4)
    }
    
    //MARK: - Buttons
    
    var allLocationsButton: some View {
        Button(action: allTapped) {
            Text(self.showingMoreAllLocations ? "Less" : "More")
        }
    }
    
    private var failedLocationsButton: some View {
        Button(action: moreFailedTapped) {
            Text(self.showingMoreFailedLocations ? "Less" : "More")
        }
    }
    
    var createGeoFireCoordsButton: some View {
        Button(action: createGFCTapped) {
            Text("Create GeoFire Coordinates")
                .font(.subheadline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(.orange))
        }
    }
    
    
    //MARK: - Methods
    
    private func allTapped() {
        self.showingMoreAllLocations.toggle()
    }
    
    private func moreFailedTapped() {
        self.showingMoreFailedLocations.toggle()
    }
    
    private func createGFCTapped() {
        for loc in locationStore.hauntedHotels {
            GeoFireManager.instance.createSpookySpotForLocation(loc) { result in
                if result == false {
                    self.failedLocations.append(loc)
                } else {
                    self.failedLocations.removeAll(where: { $0.id == loc.id })
                }
            }
        }
    }
}

struct DatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseView()
    }
}
