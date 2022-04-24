//
//  Trip.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation
import CoreLocation

class Trip {
    static let instance = Trip()
        
    var startLocation: TripLocation
    var endLocation: TripLocation
    var locations: [TripLocation]
//    {
//        didSet {
//            tripPageVM.tripLocations.removeAll()
//            tripPageVM.tripLocations = oldValue
//        }
//    }
    var duration: Double
    var miles: Double
    
    var durationAsString: String {
        secondsToHoursString(duration)
    }
    
    var milesAsString: String {
        String(format: "%.0f mi", miles)
    }
    
    var hasEditedStartOrEnd = false
    
    init() {
        self.startLocation = TripLocation()
        self.endLocation = TripLocation()
        self.locations = []
        self.duration = 0
        self.miles = 0
    }
    
    init(startLocation: TripLocation, endLocation: TripLocation, locations: [TripLocation], duration: Double, miles: Double) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.locations = locations
        self.duration = duration
        self.miles = miles
    }
//    
//    init() {
//        startLocation = Location(
//            id: TripDetails.startLocationID,
//            name: MapDetails.startingLocationName,
//            cLLocation: MapDetails.startingLocation, baseImage: nil)
//        endLocation = Location(
//            id: TripDetails.endLocationID,
//            name: MapDetails.startingLocationName,
//            cLLocation: MapDetails.startingLocation, baseImage: nil)
//        locations = []
//    }
    
    func setCurrentLocationTo(_ place: TripDetails) {
        guard let cLLocation = UserStore.instance.currentLocation else { return }

        switch place {
        case .start:
            startLocation = TripLocation(id: "\(TripDetails.startLocationID)", name: "Current Location", cLLocation: cLLocation)
        case .end:
            endLocation = TripLocation(id: "\(TripDetails.endLocationID)", name: "Current Location", cLLocation: cLLocation)
        }
    }
    
    func secondsToHoursString(_ seconds: Double) -> String {
        let minutes = seconds / 60
        if minutes / 60 < 1 {
            return "\(minutes) mins"
        } else {
            let hours = (minutes / 60).rounded(.down)
            let remainingMinutes = (((minutes / 60) - hours) * 60)
            return "\(hours) hrs \(remainingMinutes) mins"
        }
    }
    
    func setTripDuration() {
        var time: Double = 0
        TripPageVM.instance.routes.forEach { route in
            time = route.expectedTravelTime
            self.duration = time
        }
    }
    func addLocationToList(location: Location) {
        
        FirebaseManager.instance.getCoordinatesFromAddress(address: location.address?.geoCodeAddress() ?? "") { cloc in
        
            let newTripLoc = TripLocation(id: "\(location.id)", name: location.name, cLLocation: cloc)
            self.locations.append(newTripLoc)
            
            TripPageVM.instance.tripLocationsForAnnotations.append(
                LocationAnnotationModel(
                    coordinate: cloc.coordinate,
                    locationID: "\(location.id)"))
        }
    }
    
    func removeLocationFromList(tripLoc: TripLocation) {
        if listContainsLocation(tripLoc: tripLoc) {
            locations.removeAll { $0 == tripLoc }
        }
    }
    
    func addOrSubtractFromTrip(location: Location) {
        if listContainsLocation(location: location) {
            removeLocationFromList(tripLoc: TripLocation(id: "\(location.id)", name: location.name, cLLocation: CLLocation()))
        } else {
            addLocationToList(location: location)
        }
    }

    
    func listContainsLocation(tripLoc: TripLocation) -> Bool {
        locations.contains(tripLoc)
    }
    /// both needed
    func listContainsLocation(location: Location) -> Bool {
        let tripLoc = TripLocation(id: "\(location.id)", name: location.name, cLLocation: CLLocation())
        return locations.contains(tripLoc)
    }
    
}

enum TripDetails {
    static let startLocationID = 23678945
    static let endLocationID = 45897631
    
    case start
    case end
}
