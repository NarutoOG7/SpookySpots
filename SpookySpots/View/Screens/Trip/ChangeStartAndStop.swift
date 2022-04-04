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
                TextField("", text: $textInput) { startedEditing in
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
    @ObservedObject var tripPageVM = TripPageVM.instance
    
    @State var startInput = TripPageVM.instance.trip?.startLocation?.name ?? ""
    @State var endInput = TripPageVM.instance.trip?.endLocation?.name ?? ""
    
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
                    CustomTextInputViewWithTextLabel(labelText: "Start", textInput: $startInput, searchForStart: $isEditingStart, searchForEnd: $isEditingEnd)
                    CustomTextInputViewWithTextLabel(labelText: "End", textInput: $endInput, searchForStart: $isEditingStart, searchForEnd: $isEditingEnd)
                    
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
        tripPageVM.isShowingSheetForStartOrStop = false
    }
    
    func addStartAndStopToTrip() {
        guard let trip = TripPageVM.instance.trip else { return }
        if !startInput.isEmpty && startInput != "Current Location" && !endInput.isEmpty && endInput != "Current Location" {
            
            let startLat = startMKItem.placemark.coordinate.latitude
            let startLon = startMKItem.placemark.coordinate.longitude
            
            let newLat = endMKItem.placemark.coordinate.latitude
            let newLon = endMKItem.placemark.coordinate.longitude
            
            let newStartingLocation = Location(
                id: TripDetails.startLocationID,
                name: startInput,
                cLLocation: CLLocation(latitude: startLat, longitude: startLon), baseImage: nil)
            
            let newEndingLocation = Location(
                id: TripDetails.endLocationID,
                name: endInput,
                cLLocation: CLLocation(latitude: newLat, longitude: newLon), baseImage: nil)
            let newTrip = Trip(start: newStartingLocation, end: newEndingLocation, locations: trip.locations, duration: trip.duration, miles: trip.miles)
//            trip.startLocation = newStartingLocation
//            trip.endLocation = newEndingLocation
            tripPageVM.trip = newTrip
            
            tripPageVM.isShowingSheetForStartOrStop = false
        } else {
            cancel()
        }
    }
}
struct ChangeStartAndStop_Previews: PreviewProvider {
    static var previews: some View {
        ChangeStartAndStop()
    }
}
