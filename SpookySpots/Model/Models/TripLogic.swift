////
////  TripLogic.swift
////  SpookySpots
////
////  Created by Spencer Belton on 5/7/22.
////
//
//
//import SwiftUI
//import MapKit
//
//class TripLogic: ObservableObject {
//    static let instance = TripLogic()
//
//    private var trips: [Trip] = []
//    private var currentTrip: Trip?
//
//    @ObservedObject var userStore = UserStore.instance
//    @ObservedObject var firebaseManager = FirebaseManager.instance
//
//    init() {
//        // load from firebase
//        if userStore.isSignedIn {
//            firebaseManager.getTripLocationsForUser { trip in
//                self.trips.append(trip)
//
//                self.currentTrip = self.trips.last
//            }
//        }
//    }
//
//    func destinationsContains(_ location: LocationModel) -> Bool {
//        if let trip = currentTrip {
//           return trip.destinations.contains(where:  { $0.name == location.location.name})
//        } else {
//            return false
//        }
//    }
//
//    func addDestination(_ location: LocationModel) {
//        objectWillChange.send()
//
//        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
//
//            let destination = Destination(lat: cloc.coordinate.latitude, lon: cloc.coordinate.longitude, name: location.location.name)
//            self.currentTrip?.destinations.append(destination)
//        }
//    }
//
//    func removeDestination(_ location: LocationModel) {
//        objectWillChange.send()
//        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
//    }
//
//    func getRoutes(withCompletion completion: @escaping ((_ route: MKRoute) -> (Void))) {
//        guard let trip = trip else { return }
//        if let trip = currentTrip {
//            var last = trip.startLocation
//        for location in trip.destinations {
//            if location!= last {
//                let lastCLLocation = last.cLLocation
//                let lastPlacemark = MKPlacemark(coordinate: lastCLLocation.coordinate)
//                let destPlacemark = MKPlacemark(coordinate: location.cLLocation.coordinate)
//
//                getRouteFromPointsAB(a: lastPlacemark, b: destPlacemark) { (route) -> (Void) in
//                    completion(route)
//                }
//                last = location
//            }
//        }
//        }
//    }
//
//    func getRouteFromPointsAB(a: MKPlacemark, b: MKPlacemark, withCompletion completion: @escaping ((_ route: MKRoute) -> (Void))) {
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: a)
//        request.destination = MKMapItem(placemark: b)
//        request.transportType = .automobile
//
//        let directions = MKDirections(request: request)
//        directions.calculate { (response, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            guard let route = response?.routes.first else { return }
//            print(route)
//            completion(route)
//        }
//    }
//
//}
