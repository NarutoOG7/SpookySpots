//
//  AppDelegate.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import Firebase
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        return true
    }
}
