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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//            FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        locationManager.checkIfLocationServicesIsEnabled()

        getUserIfSignedIn()

        return true
    }
    
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
}
