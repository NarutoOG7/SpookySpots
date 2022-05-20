//
//  TripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//

import SwiftUI

struct TripPage: View {
    
    @State var slideCardCanMove = true
    @State private var editMode: EditMode = .inactive
    
    @ObservedObject var locationStore = LocationStore.instance
    @EnvironmentObject var tripLogic: TripLogic
    
    private let map = MapForTrip()
    
    var body: some View {
        
        ZStack {
            
            map
                .ignoresSafeArea()
            
            
            SlideOverCard(position: .bottom,
                          canSlide: $slideCardCanMove,
                          color: .white,
                          handleColor: .black)
                          { trip }
                          
        }
        
        .onChange(of: locationStore.activeTripLocations, perform: { newValue in
            if newValue == [] {
                self.editMode = .inactive
                self.slideCardCanMove = true
            }
        })
        
        .environment(\.editMode, $editMode)
    }
    
    private var trip: some View {
        let view: AnyView
        if locationStore.activeTripLocations.isEmpty {
            view = AnyView(emptyTripView)
        } else {
            view = AnyView(tripView)
        }
        return view
    }
    
    private var emptyTripView: some View {
        Text("Add locations to your trip.")
    }
    
    private var tripView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
            
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    durationView
                    distanceView
                }
                Spacer()
                directionsButton
                    
            }
            
            startEnd
                    .padding(.vertical)
        }
         destinationList
        }
        .padding(.horizontal)
    }
    
    private var distanceView: some View {
        HStack(spacing: 16) {
            Text(tripLogic.distanceAsString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("miles")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    private var durationView: some View {
        HStack(spacing: 10) {
            Text(tripLogic.durationHoursString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("hr")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(tripLogic.durationMinutesString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("min")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    private var startEnd: some View {
        VStack(alignment: .trailing) {
            
            HStack {
                Text("START:")
                    .font(.avenirNextRegular(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                startLink
            }
            
            HStack {
                Text("END:")
                    .font(.avenirNextRegular(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                endLink
            }
        }
    }
    
    private var destinationList: some View {
        VStack {
            
            editButton
            List {
                ForEach(locationStore.activeTripLocations) { destination in
                    Text(destination.name)
                }
                .onMove(perform: moveRow(_:_:))
                .onDelete(perform: deleteRow(_:))
            }.listStyle(.inset)
                .disabled(editMode == .inactive
                )
                
            
        }
    }
    
    //MARK: - Buttons/Links
    
    private var directionsButton: some View {
        Button(action: directionsTapped) {
            Text("Get Directions")
                .padding(10)
        }
        .buttonStyle(.borderedProminent)
    }
    
    
    private var startLink: some View {
        NavigationLink {
//            ChangeStartAndStop()
            LD(location: LocationModel.example)
        } label: {
            Text(tripLogic.currentTrip?.startLocation.name ?? "Not Here")
        }
    }
    
    private var endLink: some View {
        NavigationLink {
//            ChangeStartAndStop()
            LD(location: LocationModel.example)
        } label: {
            Text(tripLogic.currentTrip?.endLocation.name ?? "Not Here")
        }
    }
    
    private var editButton: some View {
        let view: AnyView
        if locationStore.activeTripLocations == [] {
            view = AnyView(EmptyView())
        } else {
            view = AnyView(Button(action: editTapped) {
                Text(editMode == .inactive ? "Edit" : "Done")
                    .tint(Color.red)
            })
        }
        return view
    }
    
    
    //MARK: - Methods
    
    private func directionsTapped() {
        tripLogic.startDirections()
    }
    
    private func moveRow(_ source: IndexSet, _ destination: Int) {
        if var trip = tripLogic.currentTrip {
            if trip.destinations.indices.contains(destination) {
            trip.destinations.move(fromOffsets: source, toOffset: destination)
            }
        }
        locationStore.activeTripLocations.move(fromOffsets: source, toOffset: destination)
        tripLogic.destinations.move(fromOffsets: source, toOffset: destination)

        editMode = .active
    }
    
    private func deleteRow(_ source: IndexSet) {
        if let row = source.last {
            if var trip = tripLogic.currentTrip {
                if trip.destinations.indices.contains(row) {
                    trip.destinations.remove(at: row )
                }
            }
            if tripLogic.destinations.indices.contains(row) {
                tripLogic.destinations.remove(at: row)
            }
            locationStore.activeTripLocations.remove(at: row)
        }
    }
    
    private func editTapped() {
        if editMode == .inactive {
            editMode = .active
            self.slideCardCanMove = false
        } else {
            editMode = .inactive
            self.slideCardCanMove = true
        }
    }
    
   
    
    
}

struct TripPage_Previews: PreviewProvider {
    static var previews: some View {
        TripPage()
            .environmentObject(TripLogic())
    }
}
