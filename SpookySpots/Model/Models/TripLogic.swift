//
//  TripLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//


import SwiftUI
import MapKit

struct Route: Identifiable {
    let id: String
    let rt: MKRoute
    let collectionID: String
    let polyline: RoutePolyline
}

class TripLogic: ObservableObject {
    static let instance = TripLogic()

    @Published var destinations: [Destination] = [] {
        willSet {
            self.getRoutes()
        }
    }
    
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    
    @Published var availableRoutes: [Route] = [] {
        willSet {
            if let last = newValue.last {
                let polyline = RoutePolyline(points: last.polyline.points(), count: last.polyline.pointCount)
                polyline.parentCollectionID = last.collectionID
                self.inactivePolylines.append(polyline)
            }
        }
    }
    @Published var chosenRoutes: [Route] = [] {
        willSet {
            if let last = newValue.last {
                let polyline = RoutePolyline(points: last.polyline.points(), count: last.polyline.pointCount)
                polyline.parentCollectionID = last.collectionID
                self.activePolylines.append(polyline)
            }
        }
    }
    
    private var distance: Double = 0
    @Published var distanceAsString = "0"
    
    private var duration: Double = 0
    @Published var durationHoursString = "0"
    @Published var durationMinutesString = "0"
    
    @Published var navigation = MKRoute()
    
    @Published var mapRegion = MKCoordinateRegion()
    @Published var destAnnotations: [LocationAnnotationModel] = []
    
    @Published var activePolylines: [RoutePolyline] = []
    @Published var inactivePolylines: [RoutePolyline] = []

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
                                   isActive: true,
                                   destinations: [],
                                   startLocation: startLoc,
                                   endLocation: endLoc)
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
            if let currentTrip = self.currentTrip {
                
                self.currentTrip?.destinations.append(destination)
            }
            self.destinations.append(destination)
            self.locationStore.activeTripLocations.append(destination)
        }
    }

    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
        self.locationStore.activeTripLocations.removeAll(where: { $0.name == location.location.name })
        self.destinations.removeAll(where: { $0.name == location.location.name })
    }
    
    //MARK: - Distance
    
    func setDistance() {
        for route in self.chosenRoutes {
            self.distance += route.rt.distance
            self.distanceAsString = String(format: "%.0f", self.distance)
        }
    }
    
    
    //MARK: - Duration
    
    func setDuration() {
        for route in self.chosenRoutes {
            self.duration += route.rt.expectedTravelTime
            self.durationHoursString = "\(secondsToHoursMinutes(duration).hours)"
            self.durationMinutesString = "\(secondsToHoursMinutes(duration).minutes)"
        }
    }
    
    func secondsToHoursMinutes(_ seconds: Double) -> (hours: Int, minutes: Int) {
        return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60)
    }
    
    //MARK: -  Routes
    
    private func getRoutes() {
        if let trip = currentTrip {
            var last = trip.startLocation
            for location in trip.destinations {
                if location != last {
                    let lastCLLocation = CLLocation(latitude: last.lat, longitude: last.lon)
                    let lastPlacemark = MKPlacemark(coordinate: lastCLLocation.coordinate)
                    let destPlacemark = MKPlacemark(coordinate: CLLocation(latitude: location.lat, longitude: location.lon).coordinate)

                    getRouteFromPointsAB(a: lastPlacemark, b: destPlacemark)
                    last = location
                }
            }
        }

    }

    private func getRouteFromPointsAB(a: MKPlacemark, b: MKPlacemark) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: a)
        request.destination = MKMapItem(placemark: b)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let response = response else { return }
            
            let routeCollectionID = UUID().uuidString
            
            for rt in response.routes.prefix(3) {
                
                let route = Route(id: UUID().uuidString, rt: rt, collectionID: routeCollectionID, polyline: RoutePolyline(points: rt.polyline.points(), count: rt.polyline.pointCount))
                
                if !self.chosenRoutesContainsRoute(route)
                    && !self.availableRoutesContainsRoute(route) {
                    
                    if route.rt == response.routes.first {
                        /// If it is new and the first route of collection between two points
                        self.chosenRoutes.append(route)
                    } else {
                        /// If it is new but not the first of its collection...
                        self.availableRoutes.append(route)
                    }
                    
                    
                }
            
            }
        }
    }
    
    func chosenRoutesContainsRoute(_ route: Route) -> Bool {
        chosenRoutes.contains(where: { $0.id == route.id })
    }
    
    func availableRoutesContainsRoute(_ route: Route) -> Bool {
        availableRoutes.contains(where: { $0.id == route.id })
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
