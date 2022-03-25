//
//  Trip.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation

struct Trip {
    
    var tripPageVM = TripPageVM.instance
    
    var startLocation: Location?
    var endLocation: Location?
    var locations: [Location] {
        didSet {
            tripPageVM.tripLocations.removeAll()
            tripPageVM.tripLocations = oldValue
        }
    }
    var duration: Double?
    var miles: Double?
    
    var durationAsString: String {
        secondsToHoursString(duration ?? 0)
    }
    
    var milesAsString: String {
        String(format: "%.0f mi", miles ?? 0)
    }
    
    var hasEditedStartOrEnd = false
    
    init() {
        startLocation = Location(
            id: TripDetails.startLocationID,
            name: MapDetails.startingLocationName,
            address: nil,
            description: nil,
            moreInfoLink: nil,
            review: nil,
            locationType: nil,
            cLLocation: MapDetails.startingLocation,
            tours: nil,
            imageName: nil,
            baseImage: nil,
            distanceToUser: nil)
        endLocation = Location(
            id: TripDetails.endLocationID,
            name: MapDetails.startingLocationName,
            address: nil,
            description: nil,
            moreInfoLink: nil,
            review: nil,
            locationType: nil,
            cLLocation: MapDetails.startingLocation,
            tours: nil,
            imageName: nil,
            baseImage: nil,
            distanceToUser: nil)
        locations = []
    }
    
    init?(start: Location?, end: Location?, locations: [Location], duration: Double?, miles: Double?) {
        self.startLocation = start
        self.endLocation = end
        self.locations = locations
        self.duration = duration
        self.miles = miles
    }
    
    mutating func setCurrentLocationTo(_ place: TripDetails) {
        guard let cLLocation = UserStore.instance.currentLocation else { return }

        switch place {
        case .start:
            startLocation = Location(
                id: TripDetails.startLocationID,
                name: "Current Location",
                address: nil,
                description: nil,
                moreInfoLink: nil,
                review: nil,
                locationType: nil,
                cLLocation: cLLocation,
                tours: nil,
                imageName: nil,
                baseImage: nil,
                distanceToUser: nil)
        case .end:
            endLocation = Location(
                id: TripDetails.endLocationID,
                name: "Current Location",
                address: nil,
                description: nil,
                moreInfoLink: nil,
                review: nil,
                locationType: nil,
                cLLocation: cLLocation,
                tours: nil,
                imageName: nil,
                baseImage: nil,
                distanceToUser: nil)
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
    
    mutating func setTripDuration() {
        var time: Double = 0
        tripPageVM.routes.forEach { route in
            time = route.expectedTravelTime
            self.duration = time
        }
    }
    mutating func addLocationToList(location: Location) {
        locations.append(location)
    }
    
    mutating func removeLocationFromList(location: Location) {
        if listContainsLocation(location: location) {
            locations.removeAll { $0 == location }
        }
    }
    
    func addOrSubtractFromTrip(location: Location) {
        if (tripPageVM.trip?.listContainsLocation(location: location) ?? false) {
            tripPageVM.trip?.removeLocationFromList(location: location)
        } else {
            tripPageVM.trip?.addLocationToList(location: location)
        }
    }

    
    func listContainsLocation(location: Location) -> Bool {
        locations.contains(location)
    }
}

enum TripDetails {
    static let startLocationID = 23678945
    static let endLocationID = 45897631
    
    case start
    case end
}
