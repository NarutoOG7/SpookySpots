//
//  TripLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//


import SwiftUI
import MapKit

class TripLogic: ObservableObject {
    static let instance = TripLogic()

    private var destinations: [Destination] = []
    
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    @Published var routes: [MKRoute] = []
    
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var destAnnotations: [LocationAnnotationModel] = []

    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance

    init() {
        
        if userStore.isSignedIn {
            
            // load from firebase
            firebaseManager.getTripLocationsForUser { trip in
                self.trips.append(trip)
            }
            
            self.currentTrip = self.trips.last
            self.destinations = self.currentTrip?.destinations ?? []
            
            if let trip = currentTrip {
                
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
            
            getRoutes { route in
                self.routes.append(route)
            }
        }
    }

    func destinationsContains(_ location: LocationModel) -> Bool {
        if let trip = currentTrip {
           return trip.destinations.contains(where:  { $0.name == location.location.name})
        } else {
            return false
        }
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
        }
    }

    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
    }

    func getRoutes(withCompletion completion: @escaping ((_ route: MKRoute) -> (Void))) {
        if let trip = currentTrip {
            var last = trip.startLocation
            for location in trip.destinations {
                if location != last {
                    let lastCLLocation = CLLocation(latitude: last.lat, longitude: last.lon)
                    let lastPlacemark = MKPlacemark(coordinate: lastCLLocation.coordinate)
                    let destPlacemark = MKPlacemark(coordinate: CLLocation(latitude: location.lat, longitude: location.lon).coordinate)
                    
                    getRouteFromPointsAB(a: lastPlacemark, b: destPlacemark) { (route) -> (Void) in
                        completion(route)
                    }
                    last = location
                }
            }
        }
    }

    func getRouteFromPointsAB(a: MKPlacemark, b: MKPlacemark, withCompletion completion: @escaping ((_ route: MKRoute) -> (Void))) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: a)
        request.destination = MKMapItem(placemark: b)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let route = response?.routes.first else { return }
            print(route)
            completion(route)
        }
    }

}
