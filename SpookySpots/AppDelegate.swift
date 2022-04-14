//
//  AppDelegate.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import Firebase
import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {
    
    private var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    @ObservedObject var locationManager = UserLocationManager.instance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        locationManager.checkIfLocationServicesIsEnabled()

        return true
    }
}
