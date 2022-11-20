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
    
    private var signedInUser = UserDefaults.standard.data(forKey: K.UserDefaults.user)
    private var isGuest = UserDefaults.standard.data(forKey: K.UserDefaults.isGuest)
    
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance

    let persistController = PersistenceController.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        Database.database().isPersistenceEnabled = true

        locationManager.checkIfLocationServicesIsEnabled()

        getUserIfSignedIn()
        
        checkIfIsGuest()

        return true
    }
    
    
    func getUserIfSignedIn() {
        
        if let data = UserDefaults.standard.data(forKey: K.UserDefaults.user) {
            
            do {
                let decoder = JSONDecoder()

                let user = try decoder.decode(User.self, from: data)

                userStore.user = user
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
    
    func checkIfIsGuest() {
        if let data = UserDefaults.standard.data(forKey: K.UserDefaults.isGuest) {
            
            do {
                let decoder = JSONDecoder()
                let isGuest = try decoder.decode(Bool.self, from: data)
                userStore.isGuest = isGuest
            } catch {
                print("Unable to Decode Note (\(error)")
            }
        }
    }
    

}
