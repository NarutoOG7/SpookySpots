//
//  TheTripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/3/22.
//

import SwiftUI

struct TheTripPage: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @State var tripTitleInput = "Pen"
    
    @State var isShowingMoreSteps = false
    
    @State var isShowingEditSheet = false
    
    @State var destinations: [Destination] = []
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    private var map = MapViewUI(mapIsForExplore: false)
    
    var body: some View {
        ZStack {
            map
                .ignoresSafeArea()
                .environmentObject(TripLogic.instance)
            
            if tripLogic.isNavigating {
                currentLocationButton
                routeStepHelper
            } else if tripLogic.routeIsHighlighted {
                    RouteHelper()
                    .padding(.top, 40)
            }
            SlideOverCard(position: .middle, canSlide: .constant(true), color: weenyWitch.black, handleColor: weenyWitch.orange) { () -> AnyView in
                if tripLogic.currentTrip?.destinations == [] {
                    return AnyView(emptyTripView)
                } else {
                    return AnyView(trip)
                }
            }
        }
        
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            self.destinations = []
            self.destinations.append(tripLogic.currentTrip?.startLocation ?? Destination())
            tripLogic.currentTrip?.destinations.forEach({ self.destinations.append($0) })
            self.destinations.append(tripLogic.currentTrip?.endLocation ?? Destination())
        }
        
 
    }
    
    
    private var trip: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    destinationTitle
                    totalTripDetails
                }
                Spacer()
                huntButton
            }
            .padding(.horizontal, 30)
            DestinationsList(destinations: $destinations,
                             mainColor: weenyWitch.lightest,
                             accentColor: weenyWitch.light)
                .padding()
                .padding(.top, 10)
        }
    }
    
    private var emptyTripView: some View {
        Text("Add locations to your trip.")
            .foregroundColor(weenyWitch.orange)
            .font(.system(size: 22, weight: .medium))
    }
    
    var destinationTitle: some View {
        UserInputCellWithIcon(input: $tripTitleInput,
                              primaryColor: weenyWitch.lightest,
                              accentColor: weenyWitch.light,
                              icon: nil,
                              placeholderText: "Name Your Trip",
                              errorMessage: "",
                              shouldShowErrorMessage: .constant(false),
                              isSecured: .constant(false),
                              hasDivider: false,
                              boldText: true)
        .padding(.top, -40)
        .padding(.leading, -15)
//        TextField("Trip A*", text: $tripTitleInput)
//            .foregroundColor(weenyWitch.lightest)
//            .font(.system(size: 22, weight: .medium))
    }
    
    private var totalTripDetails: some View {
        DurationDistanceString(time: tripLogic.totalTripDurationAsTime,
                               distanceString: tripLogic.totalTripDistanceAsLocalUnitString)
        .foregroundColor(weenyWitch.lightest)

    }
    
 
    
    //MARK: - Buttons
    
    private var huntButton: some View {
        Button(action: huntTapped) {
            Text("HUNT")
                .foregroundColor(weenyWitch.orange)
                .padding()
                .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(weenyWitch.orange, lineWidth: 4)
                )
        }
    }
    
    private var currentLocationButton: some View {
        VStack {
            HStack {
                Spacer()
                
                CircleButton(size: .small,
                             image: Image(systemName: "location"),
                             mainColor: weenyWitch.orange,
                             accentColor: weenyWitch.black,
                             clicked: currentLocationPressed)
                
            }
            Spacer()
        }
        .padding(. horizontal, 10)
        .padding(.top, 180)
    }
    
    //MARK: - Methods
    
    private func huntTapped() {
        // Start Navigation
        if tripLogic.isNavigating {
            tripLogic.endDirections()
        } else {
            tripLogic.startTrip()
        }
        tripLogic.isNavigating.toggle()
    }
    
    private func currentLocationPressed() {
        // map . set currentLocation Region
        map.setCurrentLocationRegion()
    }

}

struct TheTripPage_Previews: PreviewProvider {
    static var previews: some View {
        TheTripPage()
    }
}

//MARK: - Navigation
extension TheTripPage {
private var routeStepHelper: some View {
    VStack {
        VStack {
            currentStep
            if isShowingMoreSteps {
                allRemainingSteps
                    .frame(maxHeight: 500)
            }
            
        }
//            .padding(.top, 100)
        .padding()
        .padding(.top, 20)
        .background(.black)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
        Spacer()
        
    }
//        .padding(.top, 75)
}
private var currentStep: some View {

    Button {
        self.isShowingMoreSteps.toggle()

    } label: {

        HStack {
//                Image("")

            if let first = tripLogic.steps.first {
                if first.instructions == "" {
                    if let second = tripLogic.steps[1] {
                        DirectionsLabel(txt: second.instructions ?? "", isShowingMore: $isShowingMoreSteps)
                    }
                } else {
                    DirectionsLabel(txt: first.instructions ?? "", isShowingMore: $isShowingMoreSteps)
                }
            }
        }
    }
}
         
private var allRemainingSteps: some View {
    List(tripLogic.steps, id: \.self) { step in
    

//        ForEach(tripLogic.steps, id: \.self) { step in
//            VStack(alignment: .leading) {
        if !tripLogic.completedSteps.contains(where: { $0 == step }) {
            if step.instructions != "" {
                Text(step.instructions ?? "")
                    .foregroundColor(.white)
                    .listRowBackground(Color.clear)
//                }
        }
        }
    }
}
}
