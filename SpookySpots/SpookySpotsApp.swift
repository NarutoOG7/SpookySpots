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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: CDTrip.entity(), sortDescriptors: []) var trips: FetchedResults<CDTrip>
    
//    @StateObject private var coreDataManager = CoreDataManager.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .environment(\.managedObjectContext, coreDataManager.context)
                .onAppear {
                    if let first = trips.first {
                        
                        var destinations: [Destination] = []
                        if let cdDests = first.destinations?.allObjects as? [CDDestination] {
                            for cdDest in cdDests {
                                let destination = Destination(id: cdDest.id ?? "",
                                                              lat: cdDest.lat,
                                                              lon: cdDest.lon,
                                                              name: cdDest.name ?? "")
                                destinations.append(destination)
                            }
                        }
                        
                        var routes: [Route] = []
                        if let cdRoutes = first.routes?.allObjects as? [CDRoute] {
                            for cdRoute in cdRoutes {
                                let route = Route(id: cdRoute.id ?? "",
                                                  rt: MKRoute(),
                                                  collectionID: cdRoute.collectionID ?? "",
                                                  polyline: RoutePolyline(),
                                                  altPosition: 0,
                                                  tripPosition: Int(cdRoute.tripPosition) )
                                routes.append(route)
                            }
                        }
                        
                        var start = Destination()
                        var end = Destination()
                        if let endPoints = first.endPoints?.allObjects as? [CDEndPoint] {
                            if let cdStart = endPoints.first(where: { $0.id == "Start" }),
                                    let cdEnd = endPoints.first(where: { $0.id == "End" }) {
                                start = Destination(id: cdStart.destination?.id ?? "",
                                                    lat: cdStart.destination?.lat ?? 0,
                                                    lon: cdStart.destination?.lon ?? 0,
                                                    name: cdStart.destination?.name ?? "")
                                    end = Destination(id: cdEnd.destination?.id ?? "",
                                                      lat: cdEnd.destination?.lat ?? 0,
                                                      lon: cdEnd.destination?.lon ?? 0,
                                                      name: cdEnd.destination?.name ?? "")
                                }
                            }
                        
                        tripLogic.currentTrip = Trip(id: first.id ?? "",
                                                     userID: first.userID ?? "",
                                                     isActive: first.isActive,
                                                     destinations: destinations,
                                                     startLocation: start,
                                                     endLocation: end,
                                                     routes: routes)
                    }
                }
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
//        .onChange(of: tripLogic.currentTrip ?? Trip()) { newCurrentTrip in
//            persistenceController.createOrUpdateTrip(newCurrentTrip)
//        }
    }
}


