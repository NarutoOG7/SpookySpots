//
//  AppDelegate.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import Firebase
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate {
    
    private var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        } 
        return true
    }
}
