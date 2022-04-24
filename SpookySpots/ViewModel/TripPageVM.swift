//
//  TripPageVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import SwiftUI

class TripPageVM: ObservableObject {
    static let instance = TripPageVM()
    
    @ObservedObject var userLocationManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var locationStore = LocationStore.instance
    
    @Published var isShowingSheetForStartOrStop = false
    @Published var trip = Trip()
    @Published var routes: [MKRoute] = []
    @Published var mapRegion = MKCoordinateRegion(center: (UserStore.instance.currentLocation != nil) ? UserStore.instance.currentLocation!.coordinate : MapDetails.startingLocation.coordinate, span: MapDetails.defaultSpan)
    
    @Published var tripLocationsForAnnotations: [LocationAnnotationModel] = []
    

    func getRoutes(withCompletion completion: @escaping ((_ route: MKRoute) -> (Void))) {
//        guard let trip = trip else { return }
        var last = trip.startLocation
        for location in trip.locations {
            if location != last {
                let lastCLLocation = last.cLLocation 
                let lastPlacemark = MKPlacemark(coordinate: lastCLLocation.coordinate)
                let destPlacemark = MKPlacemark(coordinate: location.cLLocation.coordinate)
                
                getRouteFromPointsAB(a: lastPlacemark, b: destPlacemark) { (route) -> (Void) in
                    completion(route)
                }
                last = location
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


    func initTrip() {
//        if self.trip == nil {
//            self.trip = Trip()
//        }
//        if trip != nil {
            getRoutesInTrip()
            trip.setTripDuration()
//        }
    }
    
    func getRoutesInTrip() {
        self.routes = []
        self.getRoutes { (route) -> (Void) in
            self.routes.append(route)
            
        }
    }
    
    
    //MARK: - Get Center Of Group Of Coordinates
    
    //    func centerOfCoordinates() -> CLLocationCoordinate2D {
    //        func degreesToRadians(_ number: Double) -> Double {
    //            return number * .pi / 180
    //        }
    //
    //        func radiansToDegrees(_ number: Double) -> Double {
    //            return number * 180 / .pi
    //        }
    //
    //        var xCenter: Double = 0
    //        var yCenter: Double = 0
    //        var zCenter: Double = 0
    //
    //        for coordinateSet in coordinatesArray {
    //            // convert degrees to radians
    //            let latRadians = degreesToRadians(coordinateSet.latitude)
    //            let lonRadians = degreesToRadians(coordinateSet.longitude)
    //
    //            // convert radians to cartesian
    //            let x: Double = cos(latRadians) * cos(lonRadians)
    //            let y: Double = cos(latRadians) * sin(lonRadians)
    //            let z: Double = sin(latRadians)
    //
    //            xCenter += x
    //            yCenter += y
    //            zCenter += z
    //        }
    //
    //        // averaged cartesian coordinate
    //        xCenter /= Double(coordinatesArray.count)
    //        yCenter /= Double(coordinatesArray.count)
    //        zCenter /= Double(coordinatesArray.count)
    //
    //        // back to radians
    //        let lonCenterRadians = atan2(yCenter, xCenter)
    //        let hyp = sqrt(pow(xCenter, 2) + pow(yCenter, 2))
    //        let latCenterRadians = atan2(zCenter, hyp)
    //
    //        // back to degrees
    //        let latCenter: Double = radiansToDegrees(latCenterRadians)
    //        let lonCenter: Double = radiansToDegrees(lonCenterRadians)
    //
    //        return CLLocationCoordinate2D(latitude: latCenter, longitude: lonCenter)
    //    }
    //
}
