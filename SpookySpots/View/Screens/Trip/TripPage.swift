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
    @State private var isShowingRoutHelper = false
    @State var isNavigating = false
    @State var isShowingMoreSteps = false
    
    
    @ObservedObject var locationStore = LocationStore.instance
    @EnvironmentObject var tripLogic: TripLogic
    
    private let map = MapForTrip()
    
    var body: some View {
        
        ZStack {
            
            map
                .ignoresSafeArea()
                .environmentObject(TripLogic.instance)
            
            if isNavigating {
                currentLocationButton
                navigationHelper
            } else if tripLogic.routeIsHighlighted {
                RouteHelper()
            }
            
            
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
    
    private var navigationHelper: some View {
        VStack{
            VStack {
                currentStep
                if isShowingMoreSteps {
                    allRemainingSteps
                }
            }
            .background(.thickMaterial)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
            Spacer()
            
        }
        .padding(.top, 75)
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
                    startTripButton
                    
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
    
    private var currentStep: some View {
        
        Button {
            self.isShowingMoreSteps.toggle()
            
        } label: {
            
            HStack {
                Image("")
                
                if let first = tripLogic.tripRoutes.first?.rt.steps.first?.instructions {
                    if first == "" {
                        if ((tripLogic.tripRoutes.first?.rt.steps.indices.contains(1)) != nil) {
                           let second = tripLogic.tripRoutes.first?.rt.steps[1]
                            Text(second?.instructions ?? "bob")
                                .frame(height: 50)
                                .frame(maxWidth: UIScreen.main.bounds.width - 60)
                                .padding()
                                .overlay(alignment: .trailing) {
                                    Image(systemName: isShowingMoreSteps ? "arrow.up" : "arrow.down")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding()
                                }
                        }
                    } else {
                        Text(first)
                            .frame(height: 50)
                            .frame(maxWidth: UIScreen.main.bounds.width - 60)
                            .padding()
                            .overlay(alignment: .trailing) {
                                Image(systemName: isShowingMoreSteps ? "arrow.up" : "arrow.down")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                    }
                }

            }
        }
    }
    
    private var nextStep: some View {
        HStack {
            Image("")
            Text("Turn Left")
        }
    }
    
    private var allRemainingSteps: some View {
        List(tripLogic.currentRoute?.rt.steps ?? [], id: \.self) { step in
            Text(step.instructions)
        }
        .listStyle(.sidebar)
    }
    
    
    //MARK: - Buttons/Links
    
    private var startTripButton: some View {
        Button(action: startTripTapped) {
            Text("Start Trip")
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
    
    private var moreStepsButton: some View {
        Button(action: moreStepsTapped) {
            
        }
    }
    
    private var currentLocationButton: some View {
        VStack {
            HStack {
                Spacer()
                
                CircleButton(size: .small,
                             image: Image(systemName: "location"),
                             outlineColor: .black,
                             iconColor: .black,
                             backgroundColor: .white,
                             clicked: currentLocationPressed)
            }
            Spacer()
        }
        .padding(. horizontal, 10)
        .padding(.top, 180)
    }
    
    
    //MARK: - Methods
    
    private func startTripTapped() {
        isNavigating = true
        tripLogic.startTrip()
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
    
    private func moreStepsTapped() {
        
    }
    
    private func currentLocationPressed() {
        // map . set currentLocation Region
    }
    
    
}

struct TripPage_Previews: PreviewProvider {
    static var previews: some View {
        TripPage()
            .environmentObject(TripLogic())
    }
}

//MARK: - RouteHelper

struct RouteHelper: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                VStack {
                    
                    driveTime
                    distance
                    
                    
                    if tripLogic.alternates.indices.contains(0) {
                        ColorBar(position: 0, title: "1.", color: .green)
                    }
                    
                    if tripLogic.alternates.indices.contains(1) {
                        ColorBar(position: 1, title: "2.", color: .blue)
                    }
                    
                    if tripLogic.alternates.indices.contains(2) {
                        ColorBar(position: 2, title: "3.", color: .yellow)
                    }
                    
                    moreRoutesButton
                    
                }
                .padding()
                .background(Color.white.cornerRadius(20))
            }
            .padding()
            .padding(.top, 100)
            Spacer()
            
        }
    }
    
    //MARK: - SubViews
    
    private var driveTime: some View {
        HStack {
            Image(systemName: "car.fill")
                .font(.caption)
            Text(tripLogic.getSingleRouteDurationAsString() ?? "")
        }
        .padding(.bottom, 2)
    }
    
    private var distance: some View {
        HStack {
            Image(systemName: "fuelpump.fill")
                .font(.caption)
            Text(tripLogic.getSingleRouteDistanceAsString() )
        }
    }
    
    //MARK: - Buttons
    
    private var moreRoutesButton: some View {
        Button(action: moreRoutesTapped) {
            if tripLogic.alternateRouteState == .selected && tripLogic.selectedAlternate != nil {
                Text("DONE")
            } else if tripLogic.alternateRouteState == .showingAll {
                Text("cancel")
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
        .padding(.top)
    }
    
    //MARK: - Methods
    
    private func moreRoutesTapped() {
        tripLogic.alternatesLogic()
    }
}

//MARK: - Color Bar

struct ColorBar: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    var position: Int?
    var title: String?
    var color: Color
    
    var body: some View {
        HStack {
            Text(title ?? "")
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(width: 50, height: 12)
        }
        //        .padding(.vertical, 7)
        //        .padding(.horizontal, 12)
        .overlay(background.padding(-7))
        .onTapGesture(perform: onTapped)
    }
    
    //MARK: - Background
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 2)
            .fill(isSelected() ? .orange : .clear)
    }
    
    //MARK: - Methods
    
    private func isSelected() -> Bool {
        if let position = position {
            return tripLogic.positionIsSelected(position)
        }
        return false
    }
    
    private func onTapped() {
        if let position = position {
            tripLogic.selectAlternate(position)
        }
        tripLogic.alternateRouteState = .selected
    }
}


