//
//  TripLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//


import SwiftUI
import MapKit

enum TripState {
    case creating
    case readyToDirect
    case directing
    case paused
    case finished
    
    var buttonTitleForState: String {
        switch self {
        case .creating:
            return "Add Routes"
        case .readyToDirect:
            return "Get Directions"
        case .directing:
            return "Pause"
        case .paused:
            return "Resume"
        case .finished:
            return "End"
        }
    }
}

class TripLogic: ObservableObject {
    static let instance = TripLogic()

    @Published var destinations: [Destination] = []
    
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    @Published var availableRoutes: [MKRoute] = []
    @Published var tripState: TripState = .creating
    private var distance: Double = 0
    @Published var distanceAsString = "0"
    private var duration: Double = 0
    @Published var durationHoursString = "0"
    @Published var durationMinutesString = "0"
    
    @Published var directingRoutes: [MKRoute] = []
    
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var destAnnotations: [LocationAnnotationModel] = []

    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance

    init() {
        
        if userStore.isSignedIn || userStore.isGuest {
            
            loadFromFirebase()
            
            self.currentTrip = self.trips.last
            
            if let trip = currentTrip {
                
                self.destinations = trip.destinations
                locationStore.activeTripLocations = destinations
                self.tripState = trip.tripState
                
                mapRegion = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(
                                                    latitude: trip.startLocation.lat,
                                                    longitude: trip.startLocation.lon),
                                               span: MapDetails.defaultSpan)
                
            } else {
                                
                if let currentLoc = userStore.currentLocation {
                    
                    let startLoc = Destination(id: UUID().uuidString,
                                               lat: currentLoc.coordinate.latitude,
                                               lon: currentLoc.coordinate.longitude,
                                               name: "Current Location")
                    
                    let endLoc = Destination(id: UUID().uuidString,
                                             lat: currentLoc.coordinate.latitude,
                                             lon: currentLoc.coordinate.longitude,
                                             name: "Current Location")
                    
                currentTrip = Trip(id: UUID().uuidString,
                                   userID: userStore.user.id,
                                   tripState: .creating,
                                   destinations: [],
                                   startLocation: startLoc,
                                   endLocation: endLoc)
                    self.tripState = .creating
                    mapRegion = MapDetails.defaultRegion
            }
            }
            
        }
    }
    
    //MARK: - Firebase
    
    func loadFromFirebase() {
        firebaseManager.getTripLocationsForUser { trip in
            self.trips.append(trip)
        }
    }
    
    func saveToFirebase() {
        if let currentTrip = currentTrip {
            firebaseManager.addOrSaveTrip(currentTrip)
        }
    }

    //MARK: - Destinations
    
    func destinationsContains(_ location: LocationModel) -> Bool {
        self.destinations.contains(where:  { $0.name == location.location.name})
    }

    func addDestination(_ location: LocationModel) {
        objectWillChange.send()

        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in

            let destination = Destination(
                id: "\(location.location.id)",
                lat: cloc.coordinate.latitude,
                lon: cloc.coordinate.longitude,
                name: location.location.name)
            self.currentTrip?.destinations.append(destination)
            self.destinations.append(destination)
            self.locationStore.activeTripLocations.append(destination)
            self.tripState = .creating
        }
    }

    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.tripState = .creating
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
        self.locationStore.activeTripLocations.removeAll(where: { $0.name == location.location.name })
        self.destinations.removeAll(where: { $0.name == location.location.name })
    }
    
    //MARK: - Distance
    
    func setDistance() {
        if let route = self.availableRoutes.first {
            self.distance = route.distance
            self.distanceAsString = String(format: "%.0f", route.distance)
        }
    }
    
    
    //MARK: - Duration
    
    func setDuration() {
        if let route = self.availableRoutes.first {
            self.duration = route.expectedTravelTime
            self.durationHoursString = "\(secondsToHoursMinutes(route.expectedTravelTime).hours)"
            self.durationMinutesString = "\(secondsToHoursMinutes(route.expectedTravelTime).minutes)"
        }
    }
    
    func secondsToHoursMinutes(_ seconds: Double) -> (hours: Int, minutes: Int) {
        return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60)
    }
    
    //MARK: -  Routes
    
    func addRoutes() {
        getRoutes { routes in
            for route in routes {
                self.availableRoutes.append(route)
            }
        }
    }

    private func getRoutes(withCompletion completion: @escaping ((_ routes: [MKRoute]) -> (Void))) {
        if let trip = currentTrip {
            var last = trip.startLocation
            for location in trip.destinations {
                if location != last {
                    let lastCLLocation = CLLocation(latitude: last.lat, longitude: last.lon)
                    let lastPlacemark = MKPlacemark(coordinate: lastCLLocation.coordinate)
                    let destPlacemark = MKPlacemark(coordinate: CLLocation(latitude: location.lat, longitude: location.lon).coordinate)
                    
                    getRouteFromPointsAB(a: lastPlacemark, b: destPlacemark) { (routes) -> (Void) in
                        completion(routes)
                    }
                    last = location
                }
            }
        }
    }

    private func getRouteFromPointsAB(a: MKPlacemark, b: MKPlacemark, withCompletion completion: @escaping ((_ routes: [MKRoute]) -> (Void))) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: a)
        request.destination = MKMapItem(placemark: b)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let response = response else { return }
            let routes = Array(response.routes.prefix(3))
            completion(routes)
        }
    }

    
    //MARK: - Directions
    
    func startDirections() {
        
    }
    
    func pauseDirections() {
        
    }
    
    func resumeDirections() {
        
    }
    
    func endDirections() {
        
    }
}
