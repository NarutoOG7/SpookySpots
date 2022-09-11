////
////  TripPage.swift
////  SpookySpots
////
////  Created by Spencer Belton on 5/7/22.
////
//
//import SwiftUI
//import AVFoundation
//

//
//struct TripPage: View {
//
//    @Environment(\.managedObjectContext) var moc
//
//    @FetchRequest(entity: CDTrip.entity(), sortDescriptors: []) var trips: FetchedResults<CDTrip>
//
//    @State var slideCardCanMove = true
//    @State private var editMode: EditMode = .inactive
//    @State private var isShowingRoutHelper = false
//    @State var isShowingMoreSteps = false
//
//    @State var stepIndex = 0
//
//    @State var totalTripTime: Time = Time()
//    @State var currentRouteTime: Time = Time()
//
//    @ObservedObject var locationStore = LocationStore.instance
//    @ObservedObject var tripPageVM = TripPageVM.instance
//    @EnvironmentObject var tripLogic: TripLogic
//
//    private let map = MapForTrip()
//
//
//    var body: some View {
//
//        if tripPageVM.isShowingChangeOfStartAndStop {
//            ChangeStartAndStop()
//        } else {
//
//        ZStack {
//
//            map
//                .ignoresSafeArea()
//                .environmentObject(TripLogic.instance)
//
//            if tripLogic.isNavigating {
//                currentLocationButton
////                    currentStep
//                routeStepHelper
//
//
//
//            } else if tripLogic.routeIsHighlighted {
//                RouteHelper()
//            }
//
//
//            SlideOverCard(position: .bottom,
//                          canSlide: $slideCardCanMove,
//                          color: .white,
//                          handleColor: .black)
//            { trip }
//
//
//
//
//        }
//        .onChange(of: tripLogic.currentTrip?.destinations, perform: { newValue in
//                if newValue == [] {
//                    self.editMode = .inactive
//                    self.slideCardCanMove = true
//                }
//            })
//
//
//            .environment(\.editMode, $editMode)
//
//            .alert("Would you like to remove the destinations from the trip?", isPresented: $tripLogic.shouldShowAlertForClearingTrip) {
//                Button("NO", role: .cancel) {}
//                Button("YES", role: .destructive) {
//                    self.tripLogic.resetTrip()
//                }
//            }
//        }
//    }
//
//    private var routeStepHelper: some View {
//        VStack {
//            VStack {
//                currentStep
//                if isShowingMoreSteps {
//                    allRemainingSteps
//                        .frame(maxHeight: 500)
//                }
//
//            }
////            .padding(.top, 100)
//            .padding()
//            .padding(.top, 20)
//            .background(.black)
//            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
//            Spacer()
//
//        }
////        .padding(.top, 75)
//    }
//
//    private var trip: some View {
//        let view: AnyView
//        if (tripLogic.currentTrip?.destinations ?? []).isEmpty {
//            view = AnyView(emptyTripView)
//        } else {
//            view = AnyView(tripView)
//        }
//        return view
//    }
//
//    private var emptyTripView: some View {
//        Text("Add locations to your trip.")
//    }
//
//    private var tripView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            VStack(alignment: .leading) {
//
//                HStack {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 16) {
//                            if tripLogic.isNavigating {
//                            Text(tripLogic.currentRoute?.polyline.endLocation?.name ?? "")
//                                .font(.headline)
//                                legDurationView
//                                legDistanceView
//                            }
//                        }.padding(.trailing, tripLogic.isNavigating ? 30 : 0)
//
//
//
//                            VStack(alignment: .leading, spacing: 16) {
//                                Text("TOTAL")
//                                    .font(.caption)
//                                totalTripInfo
//                            }
//
//                    }
//
////                    Divider()
//
//                    Spacer()
//                    startTripButton
//
//                }
//
//
//                startEnd
//                    .padding(.vertical)
//            }
//            destinationList
//
//        }
//        .padding(.horizontal)
//
//
//    }
//
//    private var totalTripInfo: some View {
//        DurationDistanceString(time: tripLogic.totalTripDurationAsTime, distanceAndUnit: tripLogic.getTotalDistanceAndUnit())
//    }
//
////    private var totalDistanceView: some View {
////        HStack(spacing: 16) {
////            Text(tripLogic.totalTripDistanceAsLocalUnitString)
////                .font(.avenirNextRegular(size: 23))
////                .fontWeight(.medium)
////            Text("miles")
////                .font(.avenirNextRegular(size: 15))
////                .fontWeight(.bold)
////                .foregroundColor(.secondary)
////        }
////    }
//
//    private var legDistanceView: some View {
//        HStack(spacing: 16) {
//            Text(tripLogic.getSingleRouteDistanceAsString())
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("miles")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
////
////    private var totalDurationView: some View {
////        HStack(spacing: 10) {
////            Text("\(tripLogic.totalTripDurationAsTime.hours)")
////                .font(.avenirNextRegular(size: 23))
////                .fontWeight(.medium)
////            Text("hr")
////                .font(.avenirNextRegular(size: 15))
////                .fontWeight(.bold)
////                .foregroundColor(.secondary)
////            Text("\(tripLogic.totalTripDurationAsTime.minutes)")
////                .font(.avenirNextRegular(size: 23))
////                .fontWeight(.medium)
////            Text("min")
////                .font(.avenirNextRegular(size: 15))
////                .fontWeight(.bold)
////                .foregroundColor(.secondary)
////        }
////    }
//
//    private var legDurationView: some View {
//        HStack(spacing: 10) {
////            Text("\(tripLogic.currentRouteTravelTime?.hours ?? 0)")
//            Text("\(tripLogic.getHighlightedRouteTravelTimeAsTime()?.hours ?? 0)")
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("hr")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
////            Text("\(tripLogic.currentRouteTravelTime?.minutes ?? 0)")
//            Text("\(tripLogic.getHighlightedRouteTravelTimeAsTime()?.minutes ?? 0)")
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("min")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    private var startEnd: some View {
//        VStack(alignment: .leading) {
//
//            HStack {
//                Text("START:")
//                    .font(.avenirNextRegular(size: 15))
//                    .fontWeight(.bold)
//                    .foregroundColor(.secondary)
//                startLink
//                    .disabled(tripLogic.isNavigating)
//            }
//
//            HStack {
//                Text("END:")
//                    .font(.avenirNextRegular(size: 15))
//                    .fontWeight(.bold)
//                    .foregroundColor(.secondary)
//                endLink
//                    .disabled(tripLogic.isNavigating)
//            }
//        }
//    }
//
//    private var destinationList: some View {
//        VStack {
//            HStack {
//                editButton
//                    .padding(.leading, 20)
//                Spacer()
//            }
////
//            List {
//                ForEach(tripLogic.currentTrip?.destinations ?? []) { destination in
//                    Text(destination.name)
//                }
//                .onMove(perform: moveRow(_:_:))
//                .onDelete(perform: deleteRow(_:))
//
//            }.listStyle(.plain)
//                .disabled(editMode == .inactive)
//                .frame(height: CGFloat((tripLogic.currentTrip?.destinations ?? []).count) * 50)
//        }
//    }
//
//    private var currentStep: some View {
//
//        Button {
//            self.isShowingMoreSteps.toggle()
//
//        } label: {
//
//            HStack {
////                Image("")
//
//                if let first = tripLogic.steps.first {
//                    if first.instructions == "" {
//                        if let second = tripLogic.steps[1] {
//                            DirectionsLabel(txt: second.instructions, isShowingMore: $isShowingMoreSteps)
//                        }
//                    } else {
//                        DirectionsLabel(txt: first.instructions , isShowingMore: $isShowingMoreSteps)
//                    }
//                }
//            }
//        }
//    }
//
//
//
////                if let first = tripLogic.tripRoutes.first?.rt.steps.first?.instructions {
////                    if first == "" {
////                        if ((tripLogic.tripRoutes.first?.rt.steps.indices.contains(1)) != nil) {
////                           let second = tripLogic.tripRoutes.first?.rt.steps[1]
////                            Text(second?.instructions ?? "bob")
////                                .frame(height: 75, alignment: .bottom)
////                                .frame(maxWidth: UIScreen.main.bounds.width - 60)
////                                .padding()
////                                .overlay(alignment: .bottomTrailing) {
////                                    Image(systemName: isShowingMoreSteps ? "arrow.up" : "arrow.down")
////                                        .font(.headline)
////                                        .foregroundColor(.primary)
////                                        .padding()
////                                }
////                        }
////                    } else {
////                        Text(first)
////                            .frame(height: 75, alignment: .bottom)
////                            .frame(maxWidth: UIScreen.main.bounds.width - 60)
////                            .padding()
////                            .overlay(alignment: .bottomTrailing) {
////                                Image(systemName: isShowingMoreSteps ? "arrow.up" : "arrow.down")
////                                    .font(.headline)
////                                    .foregroundColor(.primary)
////                                    .padding()
////                            }
////                    }
////                }
//
//
//
//    private var nextStep: some View {
//        HStack {
//            Image("")
//            Text("Turn Left")
//        }
//    }
//
//    private var allRemainingSteps: some View {
//        List(tripLogic.steps, id: \.self) { step in
//
//
////        ForEach(tripLogic.steps, id: \.self) { step in
////            VStack(alignment: .leading) {
//            if !tripLogic.completedSteps.contains(where: { $0 == step }) {
//                if step.instructions != "" {
//                    Text(step.instructions)
//                        .foregroundColor(.white)
//                        .listRowBackground(Color.clear)
////                }
//            }
//            }
//        }
//
//    }
//
//
//    //MARK: - Buttons/Links
//
//    private var startTripButton: some View {
//        Button(action: startTripTapped) {
//            Text(tripLogic.isNavigating ? "END" : "Start Trip")
//                .padding(10)
//        }
//        .buttonStyle(.borderedProminent)
//    }
//
//
//    private var startLink: some View {
////        NavigationLink {
////            ChangeStartAndStop(startInput: "", endInput: "")
////        } label: {
////            Text(tripLogic.currentTrip?.startLocation.name ?? "Not Here")
////        }
//
//        Button(action: startOrEndLocationTapped) {
//            Text(tripLogic.currentTrip?.startLocation.name ?? "")
//                .disabled(tripLogic.isNavigating)
//
//        }
//
//    }
//
//    private var endLink: some View {
////        NavigationLink {
////                        ChangeStartAndStop(startInput: "", endInput: "")
//////            LD(location: LocationModel.example)
////        } label: {
////            Text(tripLogic.currentTrip?.endLocation.name ?? "Not Here")
////        }
//        Button(action: startOrEndLocationTapped) {
//            Text(tripLogic.currentTrip?.endLocation.name ?? "")
//        }
//
//    }
//
//    private var editButton: some View {
//        let view: AnyView
//        if tripLogic.isNavigating ||
//            tripLogic.currentTrip?.destinations == [] {
//            view = AnyView(EmptyView())
//        } else {
//            view = AnyView(Button(action: editTapped) {
//                Text(editMode == .inactive ? "Edit" : "Done")
//                    .tint(Color.red)
//            })
//        }
//        return view
//    }
//
//    private var moreStepsButton: some View {
//        Button(action: moreStepsTapped) {
//
//        }
//    }
//
//    private var currentLocationButton: some View {
//        VStack {
//            HStack {
//                Spacer()
//
//                CircleButton(size: .small,
//                             image: Image(systemName: "location"),
//                             mainColor: K.Colors.WeenyWitch.brown,
//                             accentColor: K.Colors.WeenyWitch.lightest,
//                             clicked: currentLocationPressed)
//
//            }
//            Spacer()
//        }
//        .padding(. horizontal, 10)
//        .padding(.top, 180)
//    }
//
//
//    //MARK: - Methods
//
//    private func startTripTapped() {
//        if tripLogic.isNavigating {
//            tripLogic.endDirections()
//        } else {
//            tripLogic.startTrip()
//        }
//        tripLogic.isNavigating.toggle()
//    }
//
//    private func moveRow(_ source: IndexSet, _ destination: Int) {
//        tripLogic.currentTrip?.destinations.move(fromOffsets: source, toOffset: destination)
////        if var trip = tripLogic.currentTrip {
//////            if trip.destinations.indices.contains(source.) {
////                trip.destinations.move(fromOffsets: source, toOffset: destination)
////            print(trip.destinations)
//////            }
////        }
//        var destinations = tripLogic.currentTrip?.destinations
//        destinations?.move(fromOffsets: source, toOffset: destination)
//        if let oldTrip = tripLogic.currentTrip {
//            let newTrip = Trip(id: oldTrip.id, userID: oldTrip.userID, isActive: oldTrip.isActive, destinations: destinations ?? [], startLocation: oldTrip.startLocation, endLocation: oldTrip.endLocation, routes: oldTrip.routes)
//            tripLogic.currentTrip = newTrip
//        }
//        tripLogic.currentTrip?.destinations.move(fromOffsets: source, toOffset: destination)
//
//
//        editMode = .active
//    }
//
//    private func deleteRow(_ source: IndexSet) {
//        if let row = source.last {
////            if var trip = tripLogic.currentTrip {
////                if trip.destinations.indices.contains(row) {
////                    trip.destinations.remove(at: row )
////                }
////            }
//            tripLogic.removeDestination(atIndex: row)
////
////            if tripLogic.destinations.indices.contains(row) {
////                tripLogic.destinations.remove(at: row)
////            }
////            locationStore.activeTripLocations.remove(at: row)
//        }
//    }
//
//    private func editTapped() {
//        if editMode == .inactive {
//            editMode = .active
//            self.slideCardCanMove = false
//        } else {
//            editMode = .inactive
//            self.slideCardCanMove = true
//        }
//    }
//
//    private func moreStepsTapped() {
//
//    }
//
//    private func currentLocationPressed() {
//        // map . set currentLocation Region
//        map.setCurrentLocationRegion()
//    }
//
//    private func startOrEndLocationTapped() {
//        tripPageVM.isShowingChangeOfStartAndStop = true
//    }
//}
//
//struct TripPage_Previews: PreviewProvider {
//    static var previews: some View {
//        TripPage()
//            .environmentObject(TripLogic())
//    }
//}
//
//
//
//
