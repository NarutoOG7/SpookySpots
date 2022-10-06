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
    
    @StateObject var network = Network()
        
    @Environment(\.scenePhase) var scenePhase
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
                ContentView()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationStore)
                .environmentObject(network)
//                .onDisappear {
//                    if let trip = TripLogic.instance.currentTrip {
//                        persistenceController.createOrUpdateTrip(trip)
//                    }
//                }

        }
        
        
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
                
            case .background:
                print("Scene is in background")
                persistenceController.save()
            case .inactive:
                print("Scene is inactive")
            case .active:
                print("Scene is active")
            @unknown default:
                print("Apple changed something.")
            }
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

