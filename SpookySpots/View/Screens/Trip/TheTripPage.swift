//
//  TheTripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/3/22.
//

import SwiftUI

struct TheTripPage: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @State var isShowingMoreSteps = false
    
    @State var isShowingEditSheet = false
    
    @State var destinations: [Destination] = []
    
    @ObservedObject var tripLogic = TripLogic.instance
        
    private var map = MapViewUI(mapIsForExplore: false)
    
    var body: some View {
        
        
        ZStack {
            map
                .environmentObject(TripLogic.instance)
            
            if let currentTrip = tripLogic.currentTrip {
                if currentTrip.tripState == .navigating {
                    ZStack {
                        currentLocationButton
                        VStack {
                            routeStepHelper
                            Spacer()
                        }
                        .position(x: 0, y: 0)

                    }
                } else if tripLogic.routeIsHighlighted {
                    RouteHelper()
                        .padding(.top, 40)
                }
            }
            SlideOverCard(position: .middle, canSlide: .constant(true), color: weenyWitch.black, handleColor: weenyWitch.orange) { () -> AnyView in
                if tripLogic.currentTrip?.destinations == [] {
                    return AnyView(emptyTripView)
                } else {
                    return AnyView(trip)
                }
            }
        }
        .edgesIgnoringSafeArea([])

        .onAppear {

            DispatchQueue.background {
                
                
                self.destinations = []
                self.destinations.append(tripLogic.currentTrip?.startLocation ?? Destination())
                tripLogic.currentTrip?.destinations.forEach({ self.destinations.append($0) })
                self.destinations.append(tripLogic.currentTrip?.endLocation ?? Destination())
            }
        }
    }
    
    
    private var trip: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    
                    if tripLogic.currentTrip?.tripState == .navigating {
                        destinationTitle
                        tripLegDetails
                    } else {
                        totalTripDetails
                    }
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
    
    
    private var destinationTitle: some View {
        //        if tripLogic.currentTrip?.destinations.indices.contains(tripLogic.currentTrip?.nextDestinationIndex ?? 0) ?? false {
        let nextDestination = tripLogic.currentTrip?.destinations[tripLogic.currentTrip?.nextDestinationIndex ?? 0]
        return AnyView(Text(nextDestination?.name ?? "")
            .foregroundColor(weenyWitch.lightest))
        //        } else {
        //            return AnyView(EmptyView())
        //        }
    }
    
    private var totalTripDetails: some View {
        DurationDistanceString(
            travelTime: tripLogic.currentTrip?.totalTimeInSeconds ?? 0,
            distanceInMeters: tripLogic.currentTrip?.totalDistanceInMeters ?? 0,
            isShortened: false,
            asStack: true)
        .foregroundColor(weenyWitch.lightest)
    }
    
    private var tripLegDetails: some View {
        let trip = tripLogic.currentTrip
        let currentRoute = trip?.routes[trip?.currentRouteIndex ?? 0]
        return  DurationDistanceString(
            travelTime: currentRoute?.travelTime ?? 0,
            distanceInMeters: currentRoute?.distance ?? 0,
            isShortened: false,
            asStack: false)
        .foregroundColor(weenyWitch.lightest)
    }
    
    
    
    //MARK: - Buttons
    
    private var huntButton: some View {
        let isFinished = tripLogic.currentTrip?.tripState == .finished
        let isHidden = tripLogic.currentTrip?.routes.isEmpty ?? true
        return Button(action: huntTapped) {
            Text(tripLogic.currentTrip?.tripState.buttonTitle() ?? "HUNT")
                .foregroundColor(
                    isFinished ? .gray : weenyWitch.orange)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isFinished ? .gray : weenyWitch.orange,
                            lineWidth: 4)
                )
        }
        .disabled(isFinished || isHidden)
        .opacity(isHidden ? 0 : 1)
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
        if tripLogic.currentTrip?.tripState == .navigating {
            tripLogic.endDirections()
        } else {
            tripLogic.startTrip()
        }
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
        
        return GeometryReader { geo in
            VStack {
                
                
                currentStep
                if isShowingMoreSteps {
                    list
                        .frame(maxHeight: 500)
                }
                
            }
            //            .padding(.top, 100)'
            .frame(width: UIScreen.main.bounds.width)
            .padding()
            //            .padding(.top, 20)
            .background(weenyWitch.black)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
            .padding(.top, geo.size.height * 0.15)
        }
    
        //        .padding(.top, 75)
    }
    private var currentStep: some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
        
        return Button {
            self.isShowingMoreSteps.toggle()
        } label: {
            DirectionsLabel(txt: orderedSteps.first?.instructions ?? "", isShowingMore: $isShowingMoreSteps)
        }
        .onAppear {
            if let first = orderedSteps.first {
                if first.instructions == "" {
                    tripLogic.currentTrip?.remainingSteps.removeAll(where: { $0 == first })
                }
            }
        }
    }
    
//    private var allRemainingSteps: some View {
//        if #available(iOS 16.0, *) {
//            return list
//                        .scrollContentBackground(.hidden)
//        } else {
//            // Fallback on earlier versions
//            return list
//        }
//    }
    
    private var list: some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
       return List(orderedSteps,
                    id: \.self) { step in
            
            
            //        ForEach(tripLogic.steps, id: \.self) { step in
            //            VStack(alignment: .leading) {
            //        if !tripLogic.completedSteps.contains(where: { $0 == step }) {
            if step != orderedSteps.first {
                if step.instructions != "" {
                    Text(step.instructions ?? "")
//                        .foregroundColor(.white)
                        .listRowBackground(Color.red)
                    //                }
                }
            }
        }
                    .modifier(ListBackgroundModifier())
    }
}


struct ListBackgroundModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
//                .background(.red)
        } else {
            content
            
        }
    }
}
