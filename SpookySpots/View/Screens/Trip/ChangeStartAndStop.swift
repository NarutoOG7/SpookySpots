//
//  ChangeStartAndStop.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit

struct CustomTextInputViewWithTextLabel: View {

    var labelText: String

    @Binding var textInput: String
    @Binding var placeholderText: String
    @Binding var searchForStart: Bool
    @Binding var searchForEnd: Bool

    @ObservedObject var localSearchService = LocalSearchService.instance

    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))

            HStack {

                Text(labelText + ":")
                    .font(.title2)
                    .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                    .offset(x: 10)
                TextField(placeholderText, text: $textInput) { startedEditing in
                    if startedEditing {
                        withAnimation {
                            if labelText == "Start" {
                                searchForStart = true
                                searchForEnd = false
                            } else {
                                searchForEnd = true
                                searchForStart = false
                            }
                        }
                    }
                } onCommit: {
                    withAnimation {
                        searchForEnd = false
                        searchForStart = false
                    }
                }
                .foregroundColor(.black)
                .offset(x: 10, y: 1)
                .onChange(of: textInput) { newValue in
                    localSearchService.locationsList.removeAll()
                    localSearchService.performSearch(from: newValue) { (result) -> (Void) in
                        localSearchService.locationsList.append(result)
                    }
                }
            }

        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 70)
    }
}

struct ChangeStartAndStop: View {

    @ObservedObject var localSearchService = LocalSearchService.instance
    @ObservedObject var tripLogic = TripLogic.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var tripPageVM = TripPageVM.instance

    @State var startInput: String
    @State var endInput: String
    
    @State var startPlaceholder: String = ""
    @State var endPlaceholder: String = ""

    @State var isEditingStart = false
    @State var isEditingEnd = false

    @State var startMKItem = MKMapItem()
    @State var endMKItem = MKMapItem()

    var body: some View {
        ZStack {

            VStack {

                HStack {
                    cancelButton
                    Spacer()
                    Text("Edit Start/Stop")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    doneButton
                }
                .padding(10)


                VStack {
                    CustomTextInputViewWithTextLabel(labelText: "Start", textInput: $startInput, placeholderText: $startPlaceholder, searchForStart: $isEditingStart, searchForEnd: $isEditingEnd)
                    CustomTextInputViewWithTextLabel(labelText: "End", textInput: $endInput, placeholderText: $endPlaceholder, searchForStart: $isEditingStart, searchForEnd: $isEditingEnd)

                    Button(action: currentLocationTapped) {
                        Text("Current Location")
                    }
                    
                    List(localSearchService.locationsList) { location in
                        Button(action: {
                            if isEditingStart {
                                startInput = location.mapItem.name ?? ""
                                startMKItem = location.mapItem
                            } else {
                                endInput = location.mapItem.name ?? ""
                                endMKItem = location.mapItem
                            }
                        }, label: {
                            Text(location.itemDisplayName())
                        })
                    }
                }

            }
            .onAppear {
                
                self.startPlaceholder = tripLogic.currentTrip?.startLocation.name ?? ""
                self.endPlaceholder = tripLogic.currentTrip?.endLocation.name ?? ""
                
            }
        }
    }

    var cancelButton: some View {
        Button(action: {
            cancel()
        }, label: {
            Text("Cancel")
                .font(.title3)
                .fontWeight(.light)

        })
    }

    var doneButton: some View {
        Button(action: {
            addStartAndStopToTrip()

        }, label: {
            Text("Done")
                .font(.title3)
                .fontWeight(.medium)
        })
    }

    func cancel() {
        tripLogic.isShowingSheetForStartOrStop = false
        tripPageVM.isShowingChangeOfStartAndStop = false
    }

    func addStartAndStopToTrip() {
        let trip = tripLogic.currentTrip

        if !startInput.isEmpty || !endInput.isEmpty {
        
        let startName = startInput == "" ? tripLogic.currentTrip?.startLocation.name : startInput
        let endName = endInput == "" ? tripLogic.currentTrip?.endLocation.name : endInput
            
            
            var startDest = Destination(id: "\(TripDetails.startingLocationID)", lat: 0, lon: 0, name: startName ?? "")
            var endDest = Destination(id: "\(TripDetails.endLocationID)", lat: 0, lon: 0, name: endName ?? "")
            
            if let currentLocation = userStore.currentLocation {
                if startName == "Current Location" {
                    startDest.lat = currentLocation.coordinate.latitude
                    startDest.lon = currentLocation.coordinate.longitude
                    
                } else {
                    let startLocCoord = startMKItem.placemark.coordinate
                    startDest.lat = startLocCoord.latitude
                    startDest.lon = startLocCoord.longitude
                }
                
                if endName == "Current Location" {
                    endDest.lat = currentLocation.coordinate.latitude
                    endDest.lon = currentLocation.coordinate.longitude
                } else {
                    let endLocCoord = endMKItem.placemark.coordinate
                    endDest.lat = endLocCoord.latitude
                    endDest.lon = endLocCoord.longitude
                }
            } else {
                /// handle error of not being able to get current location when the start is set to current location.
                /// route will not show up nor will placemark.
                /// user won't know what the fuck is happening
            }
            
            let newTrip = Trip(id: UUID().uuidString, userID: userStore.user.id, isActive: true, destinations: trip?.destinations ?? [], startLocation: startDest, endLocation: endDest, routes: trip?.routes ?? [])
//            newTrip.startLocation = newStartingLocation
//            newTrip.endLocation = newEndingLocation
            tripLogic.currentTrip = newTrip
            tripLogic.destinations = newTrip.destinations
            
            let newStartAnno = LocationAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: startDest.lat, longitude: startDest.lon), locationID: startDest.id, title: startDest.name)
            let newEndAnno = LocationAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: endDest.lat, longitude: endDest.lon), locationID: endDest.id, title: endDest.name)
            
//            tripLogic.destAnnotations = []
//            tripLogic.destAnnotations.append(newStartAnno)
//            for dest in newTrip.destinations {
//                let anno = LocationAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: dest.lat, longitude: dest.lon), locationID: dest.id, title: dest.name)
//                tripLogic.destAnnotations.append(anno)
//            }
//            tripLogic.destAnnotations.append(newEndAnno)
//            
            tripLogic.isShowingSheetForStartOrStop = false
            tripPageVM.isShowingChangeOfStartAndStop = false
        } else {
            cancel()
        }
    }
    
    func currentLocationTapped() {
        if isEditingStart {
            startInput = "Current Location"
        } else {
            endInput = "Current Location"
        }
    }
    
}
struct ChangeStartAndStop_Previews: PreviewProvider {
    static var previews: some View {
        ChangeStartAndStop(startInput: "", endInput: "")
    }
}
