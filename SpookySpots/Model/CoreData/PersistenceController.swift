//
//  PersistenceController.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/7/22.
//

import CoreData
import MapKit

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TripCDModel")
//        destroyPersistentStore()
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
//        deleteAll()
    }
    
    
    func destroyPersistentStore() {
        guard let firstStoreURL = container.persistentStoreCoordinator.persistentStores.first?.url else {
            print("Missing first store URL - could not destroy")
            return
        }

        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: firstStoreURL, type: .sqlite, options: nil)
//            try container.persistentStoreCoordinator.destroyPersistentStore(at: firstStoreURL, ofType: "", options: nil)
        } catch  {
            print("Unable to destroy persistent store: \(error) - \(error.localizedDescription)")
       }
    }
    
    
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        context.delete(object)
        save(completion: completion)
    }
    
    func deleteAll(completion: @escaping (Error?) -> () = {_ in}) {
        do {
            let context = container.viewContext
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            let trips = try context.fetch(request)
            
            for trip in trips {
                context.delete(trip)
            }
            save(completion: completion)
        } catch {
            print("Error fetching request: \(error)")
        }
    }
    
    func createOrUpdateTrip(_ trip: Trip) {
        let context = container.viewContext
        do {
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", trip.id)
            let numberOfRecords = try context.count(for: request)
            if numberOfRecords == 0 {
                let newTrip = CDTrip(context: context)
                
                print(newTrip)
                
                for route in trip.routes {
                    let routeContext = CDRoute(context: context)
                    routeContext.id = route.id
                    routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                    routeContext.collectionID = route.collectionID
                    routeContext.rtName = route.rt.name
                    routeContext.trip = newTrip
                    let mkRouteContext = CDMKRoute(context: context)
                    mkRouteContext.distance = route.rt.distance
                    mkRouteContext.expectedTravelTime = route.rt.expectedTravelTime
                    mkRouteContext.name = route.rt.name
                    routeContext.mkRoute = mkRouteContext
                    newTrip.addToRoutes(routeContext)
                    
                }
                
                print(trip.destinations)
                for dest in trip.destinations {
                    let destContext = CDDestination(context: context)
                    destContext.id = dest.id
                    destContext.lon = dest.lon
                    destContext.lat = dest.lat
                    destContext.name = dest.name
                    destContext.trip = newTrip
                    newTrip.addToDestinations(destContext)
                }
                
                
                let startContext = CDEndPoint(context: context)
                let tripStart = trip.startLocation
                startContext.position = 0
                startContext.lat = tripStart.lat
                startContext.lon = tripStart.lon
                startContext.id = "Start"
                startContext.name = tripStart.name
                startContext.trip = newTrip

                newTrip.addToEndPoints(startContext)
                
                let endContext = CDEndPoint(context: context)
                let tripEnd = trip.endLocation
                endContext.position = 1
                endContext.id = "End"
                endContext.name = tripEnd.name
                endContext.lat = tripEnd.lat
                endContext.lon = tripEnd.lon
                endContext.trip = newTrip
                
                newTrip.addToEndPoints(endContext)

                
                newTrip.id = trip.id
                newTrip.isActive = trip.isActive
                newTrip.userID = UserStore.instance.user.id
                
                print(newTrip)
                
            } else {
                // update
//                let trips = try request.execute()
                let trips = try context.fetch(request)
                if let tripToUpdate = trips.last {
                    tripToUpdate.removeFromDestinations(tripToUpdate.destinations ?? [])
                    tripToUpdate.removeFromRoutes(tripToUpdate.routes ?? [])
                    tripToUpdate.removeFromEndPoints(tripToUpdate.endPoints ?? [])
                    
                    print(tripToUpdate)

                    for route in trip.routes {
                        let routeContext = CDRoute(context: context)
   
                        routeContext.id = route.id
                        routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                        routeContext.collectionID = route.collectionID
                        routeContext.rtName = route.rt.name
                        routeContext.trip = tripToUpdate
                        let mkRouteContext = CDMKRoute(context: context)
                        mkRouteContext.distance = route.rt.distance
                        mkRouteContext.expectedTravelTime = route.rt.expectedTravelTime
                        mkRouteContext.name = route.rt.name
                        routeContext.mkRoute = mkRouteContext
                        tripToUpdate.addToRoutes(routeContext)
                    
                        
                        //            cdRoutes.append(routeContext)
                    }
                    
                    //        var cdDestinations: [CDDestination] = []
                    print(trip.destinations)
                    for dest in trip.destinations {
                        let destContext = CDDestination(context: context)
                        destContext.id = dest.id
                        destContext.lon = dest.lon
                        destContext.lat = dest.lat
                        destContext.name = dest.name
                        destContext.trip = tripToUpdate
                        tripToUpdate.addToDestinations(destContext)
                        //            cdDestinations.append(destContext)
                    }
                    
                    //        var cdEndPoints: [CDDestination] = []
                    
                    let startContext = CDEndPoint(context: context)
                    let tripStart = trip.startLocation
                    startContext.position = 0
                    startContext.lat = tripStart.lat
                    startContext.lon = tripStart.lon
                    startContext.id = tripStart.id
                    startContext.name = tripStart.name
                    startContext.trip = tripToUpdate
                    tripToUpdate.addToEndPoints(startContext)
                    
                    let endContext = CDEndPoint(context: context)
                    let tripEnd = trip.endLocation
                    endContext.position = 1
                    endContext.id = tripEnd.id
                    endContext.name = tripEnd.name
                    endContext.lat = tripEnd.lat
                    endContext.lon = tripEnd.lon
                    endContext.trip = tripToUpdate
                    tripToUpdate.addToEndPoints(endContext)
                    
                    print(tripToUpdate)
                }
                
                
            }
            
            self.save { error in
                if let error = error {
                    print("Error saving to core data: \(error.localizedDescription)")
                }
            }
            
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    func activeTrip() -> Trip? {
        do {
            let context = container.viewContext
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            let trips = try context.fetch(request)
            
            if let cdTrip = trips.last {
                print(cdTrip)
                return Trip(cdTrip)
            }
        } catch {
            print("Error fetching request: \(error)")
        }
        return nil
    }
}
