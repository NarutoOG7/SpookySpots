//
//  AppDelegate.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import CoreData
import Firebase
import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {
    
    private var signedInUser = UserDefaults.standard.data(forKey: "user")
    
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance
//    @ObservedObject var tripLogic = TripLogic.instance // calling triplogic too early creates issues.. as of right now, i do not need it anyways

    let persistController = PersistenceController.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        Database.database().isPersistenceEnabled = true

        locationManager.checkIfLocationServicesIsEnabled()

        getUserIfSignedIn()
        

        return true
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        if let trip = tripLogic.currentTrip {
//            persistController.createOrUpdateTrip(trip)
//        }
//    }
//    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        if let trip = tripLogic.currentTrip {
//            persistController.createOrUpdateTrip(trip)
//        }
//    }
    
    func getUserIfSignedIn() {
        if let data = UserDefaults.standard.data(forKey: "user") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let user = try decoder.decode(User.self, from: data)

                userStore.user = user
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        userStore.user
//    }
}
