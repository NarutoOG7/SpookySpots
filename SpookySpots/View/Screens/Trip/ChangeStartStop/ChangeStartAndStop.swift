//
//  ChangeStartAndStop.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit
import Contacts




struct ChangeStartAndStop: View {
    
    @State var startInput: String = ""
    @State var endInput: String = ""
    
    @State var startResult = MKMapItem.init()
    @State var endResult = MKMapItem.init()

    @State var startPlaceholder: String = ""
    @State var endPlaceholder: String = ""

    @State var editedField = FieldType.none

    @State var shouldShowCurrentLocationFailedErrorMessage = false
    
    @ObservedObject var localSearchService = LocalSearchService.instance
    @ObservedObject var tripLogic = TripLogic.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var tripPageVM = TripPageVM.instance
    

    let weenyWitch = K.Colors.WeenyWitch.self
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            
            VStack {
                
                StartStopCustomTextField(
                    textInput: $startInput,
                    placeholderText: $startPlaceholder,
                    editedField: $editedField,
                    type: .start)
                .padding()
                StartStopCustomTextField(
                    textInput: $endInput,
                    placeholderText: $endPlaceholder,
                    editedField: $editedField,
                    type: .end)
                .padding(.horizontal)
                .padding(.bottom)

                if !startInput.isEmpty || !endInput.isEmpty {
                    Button(action: currentLocationTapped) {
                        Text("Current Location")
                            .foregroundColor(weenyWitch.orange)
                    }
                }
                
                
                searchResultsList
                
            }
        }
            .padding(.top)
            
            .background(weenyWitch.black)
            
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .onAppear {
                                
                self.startPlaceholder = tripLogic.currentTrip?.startLocation.name ?? ""
                self.endPlaceholder = tripLogic.currentTrip?.endLocation.name ?? ""
                
            }
            .alert("Location Not Found!", isPresented: $shouldShowCurrentLocationFailedErrorMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You must allow the app permission to get your current location. Please visit your device settings.")
            }

    }

    private var searchResultsList: some View {
        List(localSearchService.locationsList) { location in
            Button(action: {
                if editedField == .start {
                    startInput = location.name ?? ""
                    startResult = location
                } else if editedField == .end {
                    endInput = location.name ?? ""
                    endResult = location
                }
            }, label: {
                VStack(alignment: .leading) {
                    Text(location.name ?? "").truncationMode(.tail)
                        .foregroundColor(weenyWitch.light)
                        .font(.title3)
                    Text(location.placemark.postalAddress?.streetCityState() ?? "")
                        .font(.caption)
                        .foregroundColor(weenyWitch.orange)

                }
            })
            .listRowBackground(Color.clear)

        }
        .modifier(ListBackgroundModifier())
    }
    
    private var errorBanner: some View {
        
        NotificationBanner(
            color: weenyWitch.orange,
            messageColor: weenyWitch.lightest,
            message: .constant("You must allow the app access to your current location."),
            isVisible: $shouldShowCurrentLocationFailedErrorMessage)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                    self.shouldShowCurrentLocationFailedErrorMessage = false
                }
            }
    }
    
    //MARK: - Buttons
    
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
    
    //MARK: - Methods

    func cancel() {
        tripLogic.isShowingSheetForStartOrStop = false
        tripPageVM.isShowingChangeOfStartAndStop = false
        self.dismiss.callAsFunction()
    }

    private func isSearching() -> Bool {
        !startInput.isEmpty || !endInput.isEmpty
    }
    
    func addStartAndStopToTrip() {
        
        let trip = tripLogic.currentTrip
        
        
        if var startDest = trip?.startLocation,
           var endDest = trip?.endLocation {
            
            if let updatedStart = updatedStart() {
                startDest = updatedStart
            }
            
            if let updatedEnd = updatedEnd() {
                endDest = updatedEnd
            }
            
            
            var newTrip = Trip(id: UUID().uuidString,
                               userID: userStore.user.id,
                               destinations: trip?.destinations ?? [],
                               startLocation: startDest,
                               endLocation: endDest,
                               routes: trip?.routes ?? [],
                               remainingSteps: trip?.remainingSteps ?? [],
                               completedStepCount: trip?.completedStepCount ?? 0,
                               totalStepCount: trip?.totalStepCount ?? 0,
                               tripState: .building)

            newTrip.nextDestinationIndex = 0
            
            if startInput != "" || endInput != "" {
                newTrip.getRoutes()
            }
            tripLogic.currentTrip = newTrip
            

            tripLogic.isShowingSheetForStartOrStop = false
            tripPageVM.isShowingChangeOfStartAndStop = false
            
            self.dismiss.callAsFunction()
        }
    }
    
    func currentLocationTapped() {
        if userStore.currentLocation != nil {
            if editedField == .start {
                startInput = "Current Location"
            } else if editedField == .end {
                endInput = "Current Location"
            }
        }
    }
    
    func updatedStart() -> Destination? {
        
        if !startInput.isEmpty {
            
            let startName = startInput == "" ? tripLogic.currentTrip?.startLocation.name : startInput
            
            let startDest = createDestinationFromResult(startResult, name: startName ?? "", isStart: true)
            
            return startDest
        }
        return nil
    }

    func updatedEnd() -> Destination? {

        if !endInput.isEmpty {
        
        let endName = endInput == "" ? tripLogic.currentTrip?.endLocation.name : endInput
            
        let endDest = createDestinationFromResult(endResult, name: endName ?? "", isStart: false)
            
            return endDest
        }
        
        
        return nil
    }
    
    
    func createDestinationFromResult(_ result: MKMapItem, name: String, isStart: Bool) -> Destination {
        let postalAddress = result.placemark.postalAddress?.streetCityState()
        let position = isStart ? 0 : (tripLogic.currentTrip?.destinations.count ?? 0 + 1)
        var newDest = Destination(
            id: isStart ? "\(TripDetails.startingLocationID)" : "\(TripDetails.endLocationID)",
            lat: 0,
            lon: 0,
            address: postalAddress ?? "",
            name: name,
            position: position)
        
        if name == "Current Location" {
            if let currentLocation = userStore.currentLocation {
                newDest.lat = currentLocation.coordinate.latitude
                newDest.lon = currentLocation.coordinate.longitude
                
            } else {
                self.shouldShowCurrentLocationFailedErrorMessage = true
                /// handle error of not being able to get current location when the start is set to current location.
                /// route will not show up nor will placemark.
                /// user won't know what the fuck is happening
            }
        } else {
            let newLocCoord = result.placemark.coordinate
            newDest.lat = newLocCoord.latitude
            newDest.lon = newLocCoord.longitude
        }
        
        return newDest
    }
    
}
struct ChangeStartAndStop_Previews: PreviewProvider {
    static var previews: some View {
        ChangeStartAndStop(startInput: "", endInput: "")
    }
}

extension Binding where Value == String? {
    func toNonOptional() -> Binding<String> {
        return Binding<String>(
            get: {
                return self.wrappedValue ?? ""
            },
            set: {
                self.wrappedValue = $0
            }
        )

    }
}

extension CNPostalAddress {
    func streetCityState() -> String {
        "\(self.street), \(self.city), \(self.state)"
    }
}
