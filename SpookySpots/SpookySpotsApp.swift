//
//  SpookySpotsApp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import MapKit

@main
struct SpookySpotsApp: App {

    
    let persistenceController = PersistenceController.shared
    
    @StateObject var locationStore = LocationStore.instance
                
    @Environment(\.scenePhase) var scenePhase
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
                ContentView()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationStore)

        }
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    func addTapGestureRecognizer() {
        guard let window = connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - UIGestureRecognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

