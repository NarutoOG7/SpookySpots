//
//  UserLocationManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import SwiftUI


enum MapDetails {
    static let startingLocation = CLLocation(latitude: 39.8097, longitude: -98.5556)
    static let startingLocationName = "Lebanon"
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
}


class UserLocationManager: NSObject, ObservableObject {
    static let instance = UserLocationManager()
    
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation.coordinate,
                                               span: MapDetails.defaultSpan)
//    @Published var radius = 50
    var locationManager: CLLocationManager?
    @Published var displayedLocationRoute: MKRoute!
    
    @ObservedObject var userStore = UserStore.instance
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            let locManager = CLLocationManager()
            locManager.activityType = .automotiveNavigation
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.delegate = self
            self.locationManager = locManager
        } else {
            print("Show alert to let user know that location services is off.")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("DEBUG: Not Determined")
        case .restricted:
            print("DEBUG: Restricted")
            print("Your location is restricted likely due to parental controls.") //Alert
        case .denied:
            print("DEBUG: Denied")
            print("You have denied this app location permission. Go into your settings to change it.") //Alert
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            if let curentLoc = locationManager.location {
                userStore.currentLocation = curentLoc
                let region = MKCoordinateRegion(center: curentLoc.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.region = region
                //                TripPageVM.instance.mapRegion = region
            }
        @unknown default:
            break
        }
    }
    
    func requestLocation() {
        locationManager?.requestLocation()
    }
    
    
    func getDistanceToLocation(location: Location, withCompletion completion: @escaping ((_ distance: Double) -> (Void))) {
        let request = MKDirections.Request()
        if let currentLocation = userStore.currentLocation {
            var destCoordinates = CLLocationCoordinate2D()
            
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
            if let locationAddress = location.address {
                
                
                getCoordinatesFrom(addressString: locationAddress.fullAddress()) { coordinates in
                    destCoordinates = coordinates
                    
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinates))
                    request.transportType = MKDirectionsTransportType.automobile
                    
                    let directions = MKDirections(request: request)
                    directions.calculate { (response, error) in
                        guard let response = response else {
                            print(error.debugDescription)
                            return
                        }
                        let route = response.routes[0]
                        print(route.distance * 0.000621)
                        completion(route.distance * 0.000621)
                    }
                }
            }
        }
    }
    
    func getCoordinatesFrom(addressString: String, withCompletion completion: @escaping ((_ coordinates: CLLocationCoordinate2D) -> (Void))) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
            else {
                // handle no location found
                print("error on forward geocoding.. get coordinates from location.. \(addressString)")
                return
            }
            completion(loc.coordinate)
        }
    }
    
    //    func getCoordinatesFrom(location: Location, withCompletion completion: @escaping ((_ coordinates: CLLocationCoordinate2D) -> (Void))) {
    //        let geoCoder = CLGeocoder()
    //        geoCoder.geocodeAddressString(location.address.fullAddress()) { (placemarks, error) in
    //            guard
    //                let placemarks = placemarks,
    //                let loc = placemarks.first?.location
    //            else {
    //                // handle no location found
    //                print("error on forward geocoding.. get coordinates from location.. \(location.name)")
    //                return
    //            }
    //            completion(loc.coordinate)
    //        }
    //    }
    
    func getAddressFrom(coordinates: CLLocationCoordinate2D, withCompletion completion: @escaping ((_ location: Address) -> (Void))) {
        let location  = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first
            else {
                // Handle error
                return
            }
            if let buildingNumber = location.subThoroughfare,
               let street = location.thoroughfare,
               let city = location.locality,
               let state = location.administrativeArea,
               let zip = location.postalCode,
               let country = location.country {
                
                let address = Address(
                    address: "\(buildingNumber) \(street)",
                    city: city,
                    state: state,
                    zipCode: zip,
                    country: country)
                completion(address)
            }
        }
    }
}



//MARK: - Get map region radius

extension MKCoordinateRegion {
    func distanceMax() -> CLLocationDistance {
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                                  longitude: center.longitude + (span.longitudeDelta/2))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return centerLoc.distance(from: furthest)
    }
}



//MARK: - LocationManagerDelegate

extension UserLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locations.last.map {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        }
        if let trip = TripPageVM.instance.trip {
            if !trip.hasEditedStartOrEnd {
                TripPageVM.instance.trip?.setCurrentLocationTo(TripDetails.start)
                TripPageVM.instance.trip?.setCurrentLocationTo(TripDetails.end)
            }
        }
    }
    
    //MARK: - Handling user loction choice
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
}



