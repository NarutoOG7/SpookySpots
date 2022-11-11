//
//  TheTripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/3/22.
//

import SwiftUI
import MapKit

struct TheTripPage: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @State var isShowingMoreSteps = false
    
    @State var isShowingEditSheet = false
    
    @State var destinations: [Destination] = []
    
    @State var shouldShowResetAlert = false
    @State var shouldShowResetButton = false
    
    @State var shouldDisplayErrorBanner = false
    
    
    @ObservedObject var tripLogic = TripLogic.instance
    @ObservedObject var userStore = UserStore.instance
        
//     @State private var map = MapViewUI(mappedPolylines: .constant([]), mappedAltPolylines: .constant([]))
    
    private let map = MapViewUI(mapIsForExplore: false)
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {

                map
                .ignoresSafeArea()
                    .environmentObject(TripLogic.instance)
                
                if let currentTrip = tripLogic.currentTrip {
                    if currentTrip.tripState == .navigating {
                        currentLocationButton
                        VStack {
                            routeStepHelper(geo)
                            Spacer()
                        }
                        
                    } else if tripLogic.routeIsHighlighted {
                        RouteHelper()
                            .padding(.top, 40)
                    }
                }
                SlideOverCard(position: .middle, canSlide: .constant(true), color: weenyWitch.black, handleColor: weenyWitch.orange, screenSize: geo.size.height) { () -> AnyView in
                    if tripLogic.currentTrip?.destinations == [] {
                        return AnyView(emptyTripView)
                    } else {
                        return AnyView(trip)
                    }
                }
            }
            .alert("Reset Trip", isPresented: $shouldShowResetAlert, actions: {
                Button("RESET", role: .destructive, action: resetConfirmedTapped)
                Button("Leave Alone", role: .cancel, action: resetCanceledTapped)
            }, message: {
                Text("Would you like to reset your trip by removing all destinations and routes?")
            })
            
            
            
            .task {
                DispatchQueue.background {
                    
                    
                    self.destinations = []
                    self.destinations.append(tripLogic.currentTrip?.startLocation ?? Destination())
                    tripLogic.currentTrip?.destinations.forEach({ self.destinations.append($0) })
                    self.destinations.append(tripLogic.currentTrip?.endLocation ?? Destination())
                }
            }
        }
    }
    
    private var trip: some View {
        let routesEmpty = tripLogic.currentTrip?.routes.isEmpty ?? true
        let shouldShowHuntButton = !destinationsAreComplete() || !routesEmpty
        return VStack(alignment: .leading) {
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
                if shouldShowHuntButton {
                    huntButton
                }
                if shouldShowResetButton {
                    resetButton
                }
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
        let nextDestination = tripLogic.currentTrip?.destinations[tripLogic.currentTrip?.nextDestinationIndex ?? 0]
        return AnyView(Text(nextDestination?.name ?? "")
            .foregroundColor(weenyWitch.lightest))
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
        let index = trip?.currentRouteIndex ?? 0
        if trip?.routes.indices.contains(index) ?? false,
           let currentRoute = trip?.routes[index] {
            return  AnyView(
                DurationDistanceString(
                    travelTime: currentRoute.travelTime,
                    distanceInMeters: currentRoute.distance,
                    isShortened: false,
                    asStack: false)
                .foregroundColor(weenyWitch.lightest))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    
    
    //MARK: - Buttons
    
    private var huntButton: some View {
        
         Button(action: huntLogic) {
            Text(tripLogic.currentTrip?.tripState.buttonTitle() ?? "HUNT")
                .foregroundColor(weenyWitch.orange)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(weenyWitch.orange,
                                lineWidth: 4)
                )
        }
    }
    
    private var resetButton: some View {
        Button {
            self.shouldShowResetAlert = true
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(weenyWitch.orange)
                .padding()
                .overlay(
                    Circle()
                        .stroke(weenyWitch.orange,
                            lineWidth: 4)
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
        .padding(.top, 100)
//        .padding(.top, 180)
    }
    
    //MARK: - Methods
    
    private func huntLogic() {
        switch tripLogic.currentTrip?.tripState {
            
        case .building:
            // Hunt Tapped
            tripLogic.startTrip()
            
        case .navigating:
            // End Tapped
            self.endTapped()
            
        case .paused:
            // Resume Tapped
            tripLogic.resumeDirections()
            self.shouldShowResetButton = false

        default: return
            
            // could do away with .finished here. and just say that the trip state is back to building ??? what about reset when all destinations are complete? what if they want to reset even without all complete? Is it easy enough to just remove locations from trip? would be if it was slide to remove and dragGesture to move becasue they are in a list like apple maps new destinations feature
        }
    }
    
    private func endTapped() {
        if self.destinationsAreComplete() {
            tripLogic.currentTrip?.tripState = .finished
            self.shouldShowResetAlert = true
        } else {
            tripLogic.pauseDirections()
        }
        self.shouldShowResetButton = true
    }
    
    
    private func currentLocationPressed() {
        map.setCurrentLocationRegion()
    }
    
    private func resetConfirmedTapped() {
        tripLogic.resetTrip()
        self.shouldShowResetButton = false
    }
    
    private func resetCanceledTapped() {
        tripLogic.currentTrip?.tripState = .paused
    }
    
    private func destinationsAreComplete() -> Bool {
        tripLogic.currentTrip?.completedDestinationsIndices.count ?? 0 >= tripLogic.currentTrip?.destinations.count ?? 0
    }
    
}

struct TheTripPage_Previews: PreviewProvider {
    static var previews: some View {
        TheTripPage()
    }
}

//MARK: - Navigation
extension TheTripPage {
    
    private func routeStepHelper(_ geo: GeometryProxy) -> some View {
        
        let maxFrameSize = geo.size.height / 2
        let fittedSize = CGFloat(tripLogic.currentTrip?.remainingSteps.count ?? 0) * 40
        let fittedIsSmallerThanMax = fittedSize < maxFrameSize
        let frameSize = fittedIsSmallerThanMax ? fittedSize : maxFrameSize
        
        return VStack {
            currentStep(geo)
            if isShowingMoreSteps {
                list
                    .frame(height: frameSize)
//                    .frame(maxHeight: geo.size.height / 2)

            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(weenyWitch.black)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    private func currentStep(_ geo: GeometryProxy) -> some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
        
        let firstStepWithText = orderedSteps.first(where: { $0.instructions != "" })
        
        return Button {
            self.isShowingMoreSteps.toggle()
        } label: {
            DirectionsLabel(
                txt: firstStepWithText?.instructions ?? "",
                geo: geo,
                isShowingMore: $isShowingMoreSteps)
            
        }
        .padding()
        
        .onAppear {
            if let first = orderedSteps.first {
                if first.instructions == "" {
                    tripLogic.currentTrip?.remainingSteps.removeAll(where: { $0 == first })
                }
            }
        }
    }
    
    private var list: some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
       return List(orderedSteps,
                    id: \.self) { step in
            
            if step != orderedSteps.first {
                if step.instructions != "" {
                    Text(step.instructions ?? "")
                        .foregroundColor(weenyWitch.light)
                        .listRowBackground(Color.clear)
                }
            }
        }
                    .modifier(ListBackgroundModifier())
                    .padding(.top, -35)
    }
}


struct ListBackgroundModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
            
        }
    }
}
