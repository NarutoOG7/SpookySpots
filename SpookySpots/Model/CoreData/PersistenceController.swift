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
        deleteAll()
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
        print(trip)
        let context = container.viewContext
        do {
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", trip.id)
            let numberOfRecords = try context.count(for: request)
            if numberOfRecords == 0 {
                let newTrip = CDTrip(context: context)
                                
                for route in trip.routes {
                    let routeContext = CDRoute(context: context)
                    routeContext.id = route.id
                    routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                    routeContext.collectionID = route.collectionID
                    routeContext.distance = route.distance
                    routeContext.travelTime = route.travelTime
                    let polylineContext = CDPolyline(context: context)
                    routeContext.polyline = polylineContext
                    if let points = route.polyline?.pts {
                        for point in points {
                            let pointContext = CDPoint(context: context)
                            pointContext.latitude = point.latitude ?? 0
                            pointContext.longitude = point.longitude ?? 0
                            pointContext.x = point.x ?? 0
                            pointContext.y = point.y ?? 0
                            pointContext.polyline = polylineContext
                            polylineContext.addToPoints(pointContext)
                        }
                    }
                    for step in route.steps {
                        let stepContext = CDStep(context: context)
                        stepContext.instructions = step.instructions
                        stepContext.longitude = step.longitude ?? 0
                        stepContext.latitude = step.latitude ?? 0
                        stepContext.distance = step.distanceInMeters ?? 0
                        stepContext.route = routeContext
                        routeContext.addToSteps(stepContext)
                    }
                    routeContext.trip = newTrip
                    newTrip.addToRoutes(routeContext)
                    
                }
                
                print(trip.destinations)
                for dest in trip.destinations {
                    let destContext = CDDestination(context: context)
                    destContext.id = dest.id
                    destContext.lon = dest.lon
                    destContext.lat = dest.lat
                    destContext.name = dest.name
                    destContext.address = dest.address
                    destContext.trip = newTrip
                    newTrip.addToDestinations(destContext)
                }
                
                
                let startContext = CDStartPoint(context: context)
                let tripStart = trip.startLocation
                startContext.lat = tripStart.lat
                startContext.lon = tripStart.lon
                startContext.id = tripStart.id
                startContext.name = tripStart.name
                startContext.address = tripStart.address
                startContext.trip = newTrip

                newTrip.startPoint = startContext
                
                let endContext = CDEndPoint(context: context)
                let tripEnd = trip.endLocation
                endContext.id = tripEnd.id
                endContext.name = tripEnd.name
                endContext.address = tripEnd.address
                endContext.lat = tripEnd.lat
                endContext.lon = tripEnd.lon
                endContext.trip = newTrip
                
                newTrip.endPoint = endContext
                
                for remainingDest in trip.remainingDestinations {
                 let remainingContext = CDRemainingDest(context: context)
                    remainingContext.id = remainingDest.id
                    remainingContext.lon = remainingDest.lon
                    remainingContext.lat = remainingDest.lat
                    remainingContext.name = remainingDest.name
                    remainingContext.address = remainingDest.address
                    remainingContext.trip = newTrip
                    newTrip.addToRemainingDestinations(remainingContext)
                }
                
                for completedDest in trip.completedDestinations {
                    let completedContext = CDCompletedDest(context: context)
                       completedContext.id = completedDest.id
                       completedContext.lon = completedDest.lon
                       completedContext.lat = completedDest.lat
                       completedContext.name = completedDest.name
                    completedContext.address = completedDest.address
                       completedContext.trip = newTrip
                       newTrip.addToCompletedDestinations(completedContext)
                }

                let nextDestContext = CDNextDestination(context: context)
                let nextDest = trip.nextDestination
                nextDestContext.id = nextDest?.id
                nextDestContext.lon = nextDest?.lon ?? 0
                nextDestContext.lat = nextDest?.lat ?? 0
                nextDestContext.name = nextDest?.name
                nextDestContext.address = nextDest?.address
                nextDestContext.trip = newTrip
                newTrip.nextDestination = nextDestContext
                
                
                let recentCompleteDestContext = CDRecentCompleteDestination(context: context)
                let recentCompleteDest = trip.nextDestination
                recentCompleteDestContext.id = recentCompleteDest?.id
                recentCompleteDestContext.lon = recentCompleteDest?.lon ?? 0
                recentCompleteDestContext.lat = recentCompleteDest?.lat ?? 0
                recentCompleteDestContext.name = recentCompleteDest?.name
                recentCompleteDestContext.address = recentCompleteDest?.address
                recentCompleteDestContext.trip = newTrip
                newTrip.recentlyCompletedDestination = recentCompleteDestContext
                
                
                
                
                newTrip.id = trip.id
                newTrip.isActive = trip.isActive
                newTrip.userID = UserStore.instance.user.id
                
                
                
            } else {
                // update
//                let trips = try request.execute()
                let trips = try context.fetch(request)
                if let tripToUpdate = trips.first {
                    tripToUpdate.removeFromDestinations(tripToUpdate.destinations ?? [])
                    tripToUpdate.removeFromRoutes(tripToUpdate.routes ?? [])

                    for route in trip.routes {
                        let routeContext = CDRoute(context: context)
   
                        routeContext.id = route.id
                        routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                        routeContext.collectionID = route.collectionID
                        routeContext.trip = tripToUpdate
                        routeContext.distance = route.distance
                        routeContext.travelTime = route.travelTime
                        
                        let polylineContext = CDPolyline(context: context)
                        for point in route.polyline?.pts ?? [] {
                            
                            let pointContext = CDPoint(context: context)
                            pointContext.latitude = point.latitude ?? 0
                            pointContext.longitude = point.longitude ?? 0
                            pointContext.x = point.x ?? 0
                            pointContext.y = point.y ?? 0
                            pointContext.polyline = polylineContext
                            polylineContext.addToPoints(pointContext)
                        }
    
                        polylineContext.route = routeContext
                        routeContext.polyline = polylineContext
                        polylineContext.route = routeContext
                        
                        
                        for step in route.steps {
                            let stepContext = CDStep(context: context)
                            stepContext.instructions = step.instructions
                            stepContext.longitude = step.longitude ?? 0
                            stepContext.latitude = step.latitude ?? 0
                            stepContext.distance = step.distanceInMeters ?? 0
                            routeContext.addToSteps(stepContext)
                        }
                        
                        tripToUpdate.addToRoutes(routeContext)
                    
                        
                    }

                    for dest in trip.destinations {
                        let destContext = CDDestination(context: context)
                        destContext.id = dest.id
                        destContext.lon = dest.lon
                        destContext.lat = dest.lat
                        destContext.name = dest.name
                        destContext.address = dest.address
                        destContext.trip = tripToUpdate
                        tripToUpdate.addToDestinations(destContext)
                        //            cdDestinations.append(destContext)
                    }
                    
                    //        var cdEndPoints: [CDDestination] = []
                    
                    let startContext = CDStartPoint(context: context)
                    let tripStart = trip.startLocation
                    startContext.lat = tripStart.lat
                    startContext.lon = tripStart.lon
                    startContext.id = tripStart.id
                    startContext.name = tripStart.name
                    startContext.address = tripStart.address
                    startContext.trip = tripToUpdate
                    tripToUpdate.startPoint = startContext
                    
                    let endContext = CDEndPoint(context: context)
                    let tripEnd = trip.endLocation
                    endContext.id = tripEnd.id
                    endContext.name = tripEnd.name
                    endContext.address = tripEnd.address
                    endContext.lat = tripEnd.lat
                    endContext.lon = tripEnd.lon
                    endContext.trip = tripToUpdate
                    tripToUpdate.endPoint = endContext
                    
                    for remainingDest in trip.remainingDestinations {
                     let remainingContext = CDRemainingDest(context: context)
                        remainingContext.id = remainingDest.id
                        remainingContext.lon = remainingDest.lon
                        remainingContext.lat = remainingDest.lat
                        remainingContext.name = remainingDest.name
                        remainingContext.address = remainingDest.address
                        remainingContext.trip = tripToUpdate
                        tripToUpdate.addToRemainingDestinations(remainingContext)
                    }
                    
                    for completedDest in trip.completedDestinations {
                        let completedContext = CDCompletedDest(context: context)
                        completedContext.id = completedDest.id
                        completedContext.lon = completedDest.lon
                        completedContext.lat = completedDest.lat
                        completedContext.name = completedDest.name
                        completedContext.address = completedDest.address
                        completedContext.trip = tripToUpdate
                        tripToUpdate.addToCompletedDestinations(completedContext)
                    }

                    let nextDestContext = CDNextDestination(context: context)
                    let nextDest = trip.nextDestination
                    nextDestContext.id = nextDest?.id
                    nextDestContext.lon = nextDest?.lon ?? 0
                    nextDestContext.lat = nextDest?.lat ?? 0
                    nextDestContext.name = nextDest?.name
                    nextDestContext.address = nextDest?.address
                    nextDestContext.trip = tripToUpdate
                    tripToUpdate.nextDestination = nextDestContext
                    
                    
                    let recentCompleteDestContext = CDRecentCompleteDestination(context: context)
                    let recentCompleteDest = trip.nextDestination
                    recentCompleteDestContext.id = recentCompleteDest?.id
                    recentCompleteDestContext.lon = recentCompleteDest?.lon ?? 0
                    recentCompleteDestContext.lat = recentCompleteDest?.lat ?? 0
                    recentCompleteDestContext.name = recentCompleteDest?.name
                    recentCompleteDestContext.address = recentCompleteDest?.address
                    recentCompleteDestContext.trip = tripToUpdate
                    tripToUpdate.recentlyCompletedDestination = recentCompleteDestContext
                    
                    
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
