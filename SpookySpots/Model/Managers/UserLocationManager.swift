//
//  UserLocationManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import SwiftUI


enum MapDetails {
    static let startingLocation = CLLocation(latitude: 45.677, longitude: -111.0429)
    static let startingLocationName = "Bozeman"
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    static let defaultRegion = MKCoordinateRegion(center: startingLocation.coordinate, span: defaultSpan)
}


class UserLocationManager: NSObject, ObservableObject {
    static let instance = UserLocationManager()
    
    @StateObject var exploreVM = ExploreViewModel.instance
    var locationManager: CLLocationManager?
    @Published var displayedLocationRoute: MKRoute!
    @Published var locationServEnabled = false
    @ObservedObject var userStore = UserStore.instance
    var firebaseManager = FirebaseManager.instance
    
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
            locationServEnabled = false
        case .denied:
            print("DEBUG: Denied")
            print("You have denied this app location permission. Go into your settings to change it.") //Alert
            locationServEnabled = false
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            if let currentLoc = locationManager.location {
                locationServEnabled = true
                userStore.currentLocation = currentLoc
//                RegionWrapper.instance.region = MKCoordinateRegion(
//                    center: curentLoc.coordinate, span: MapDetails.defaultSpan)
               exploreVM.setCurrentLocRegion(currentLoc)
            }
        @unknown default:
            break
        }
    }
    
    func requestLocation() {
        locationManager?.requestLocation()
    }
    
}



//MARK: - Get map region radius

extension MKCoordinateRegion {
    func distanceMax() -> CLLocationDistance {
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                                  longitude: center.longitude + (span.longitudeDelta/2))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return (centerLoc.distance(from: furthest) / 1609.344) * 2
    }
}



//MARK: - LocationManagerDelegate

extension UserLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locations.last.map {
            exploreVM.searchRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        }
    }
    
    //MARK: - Handling user loction choice
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
}



