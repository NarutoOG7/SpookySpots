//
//  ChangeStartStopViewModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/16/22.
//

import MapKit
import SwiftUI


class ChangeStartStopViewModel: ObservableObject {
    
    @Published var startInput: String = ""
    @Published var endInput: String = ""
    
    @Published var startResult = MKMapItem.init()
    @Published var endResult = MKMapItem.init()
    
    @Published var startPlaceholder: String = ""
    @Published var endPlaceholder: String = ""
    
    @Published var editedField = FieldType.none
    
    
    @Published var shouldShowCurrentLocationFailedErrorMessage = false

    
    @ObservedObject var tripLogic = TripLogic.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var localSearchService = LocalSearchService.instance

    
    
    func shouldShowCurrentLocationOption() -> Bool {
        !startInput.isEmpty || !endInput.isEmpty && userStore.currentLocation != nil
    }
    
    
    func buildResultsList(_ newValue: String) {
        localSearchService.locationsList.removeAll()
        localSearchService.performSearch(from: newValue) { (result) -> (Void) in
            self.localSearchService.locationsList.append(result)
        }
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
            }
        } else {
            
            let newLocCoord = result.placemark.coordinate
            
            newDest.lat = newLocCoord.latitude
            newDest.lon = newLocCoord.longitude
        }
        
        return newDest
    }
    
    func setPlaceholder() {
        self.startPlaceholder = tripLogic.currentTrip?.startLocation.name ?? ""
        self.endPlaceholder = tripLogic.currentTrip?.endLocation.name ?? ""
    }
    
    func locationChosen(_ location: MKMapItem) {
        if editedField == .start {
            startInput = location.name ?? ""
            startResult = location
        } else if editedField == .end {
            endInput = location.name ?? ""
            endResult = location
        }
    }
    
    func isSearching() -> Bool {
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
                               currentStepIndex: trip?.currentStepIndex ?? 0,
                               tripState: .building)
            
            newTrip.nextDestinationIndex = 0
            
            if startInput != "" || endInput != "" {
                newTrip.getRoutes()
            }
            tripLogic.currentTrip = newTrip
            
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
    
}
