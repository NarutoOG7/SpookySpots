//
//  UserLocationManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import SwiftUI
import AVFAudio

class UserLocationManager: NSObject, ObservableObject {
    
    static let instance = UserLocationManager()
    
    @StateObject var exploreVM = ExploreViewModel.instance
    
    @Published var displayedLocationRoute: MKRoute!
    @Published var locationServicesEnabled = false
    
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    var locationManager: CLLocationManager?
    var firebaseManager = FirebaseManager.instance
    
    func checkIfLocationServicesIsEnabled() {
        
//        DispatchQueue.global().async {
            
            
            if CLLocationManager.locationServicesEnabled() {
                
                //        if locationServicesEnabled {
                
                let locManager = CLLocationManager()
                locManager.activityType = .automotiveNavigation
                locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locManager.delegate = self
                
                self.locationManager = locManager
                
            } else {
                self.errorManager.message = "You have denied the app permission to use your location."
                self.errorManager.shouldDisplay = true
                self.checkLocationAuthorization()
            }
//        }
    }
    
    private func checkLocationAuthorization() {
        
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            print("DEBUG: Not Determined")
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("DEBUG: Restricted")
            errorManager.message = "Your location is restricted likely due to parental controls."
            errorManager.shouldDisplay = true
            
            locationServicesEnabled = false
            
        case .denied:
            print("DEBUG: Denied")
            errorManager.message = "You have denied this app location permission. Go into your settings to change it."
            errorManager.shouldDisplay = true
            
            locationServicesEnabled = false
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            
            if let currentLoc = locationManager.location {
                
                locationServicesEnabled = true
                
                userStore.currentLocation = currentLoc

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


//MARK: - LocationManagerDelegate

extension UserLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locations.last.map {
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
            
            exploreVM.searchRegion = region
        }
    }
    
    //MARK: - Handling user loction choice
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationAuthorization()
    }
    
    
    //MARK: - For TurnByTurn Navigation, Geofencing Circle Region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("ENTERED")
        
        let tripLogic = TripLogic.instance
        
        if let completed = tripLogic.currentTrip?.completedStepCount,
           let total = tripLogic.currentTrip?.totalStepCount {
            
            if completed < total {
      
                tripLogic.currentTrip?.completedStepCount += 1
                tripLogic.currentTrip?.remainingSteps.sort(by: { $0.id ?? 0 < $1.id ?? 1 })
                tripLogic.currentTrip?.remainingSteps.remove(at: 0)
                
            } else {
                
                let message = "You have arrived at your destination."
                print(message)

                tripLogic.currentTrip?.completedDestinationsIndices.append(tripLogic.currentTrip?.nextDestinationIndex ?? 0)
                tripLogic.currentTrip?.completedStepCount = 0
                tripLogic.currentTrip?.nextDestinationIndex = tripLogic.currentTrip?.remainingDestinationsIndices.first ?? 0
                tripLogic.currentTrip?.remainingDestinationsIndices.removeFirst()
                tripLogic.currentTrip?.totalStepCount = 0
                tripLogic.currentTrip?.tripState = .paused
                
                locationManager?.monitoredRegions.forEach({ locationManager?.stopMonitoring(for: $0) })
                
            }
        }
        if let currentTrip = tripLogic.currentTrip {
            
            PersistenceController.shared.createOrUpdateTrip(currentTrip)
        }
    }
    
    
}




