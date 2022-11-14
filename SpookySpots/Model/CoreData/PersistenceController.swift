//
//  PersistenceController.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/7/22.
//

import SwiftUI
import CoreData
import MapKit

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    let mainQueueContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    @ObservedObject var errorManager = ErrorManager.instance
    
    init() {
        container = NSPersistentContainer(name: "TripCDModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        self.mainQueueContext = container.viewContext
        self.backgroundContext = container.newBackgroundContext()
        self.deleteAll()
    }
    
    func deleteAll(completion: @escaping (Error?) -> () = {_ in}) {
        
        do {
//            let context = container.viewContext
            
            let context = backgroundContext
            
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            let trips = try context.fetch(request)
            
            for trip in trips {
                context.delete(trip)
            }
            save(context, completion: completion)
        } catch {
            print("Error fetching request: \(error)")
        }
    }
    
    func save(_ context: NSManagedObjectContext, completion: @escaping (Error?) -> () = {_ in}) {
        
        context.perform {
            
            
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
        save(context, completion: completion)
    }
    
    func createOrUpdateTrip(_ trip: Trip) {
        
        
        let context = backgroundContext
        context.perform {
            
            do {
                
                let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", trip.id)
                let numberOfRecords = try context.count(for: request)
                if numberOfRecords == 0 {
                    let newTrip = CDTrip(context: context)
                    
                    let startContext = CDDestination(context: context)
                    let tripStart = trip.startLocation
                    startContext.lat = tripStart.lat
                    startContext.lon = tripStart.lon
                    startContext.id = tripStart.id
                    startContext.name = tripStart.name
                    startContext.address = tripStart.address
                    
                    newTrip.startPoint = startContext
                    
                    let endContext = CDDestination(context: context)
                    let tripEnd = trip.endLocation
                    endContext.id = tripEnd.id
                    endContext.name = tripEnd.name
                    endContext.address = tripEnd.address
                    endContext.lat = tripEnd.lat
                    endContext.lon = tripEnd.lon
                    
                    newTrip.endPoint = endContext
                    
                    newTrip.id = trip.id
                    newTrip.userID = UserStore.instance.user.id
                    newTrip.completedStepCount = trip.completedStepCount
                    newTrip.totalStepCount = trip.totalStepCount
                    newTrip.tripState = trip.tripState.rawValue
                    
                    newTrip.nextDestinationIndex = Int16(trip.nextDestinationIndex ?? 0)
                    newTrip.currentRouteIndex = Int16(trip.currentRouteIndex ?? 0)
                    newTrip.remainingDestinationsIndices = NSSet(array: trip.remainingDestinationsIndices)
                    newTrip.completedDestinationsIndices = NSSet(array: trip.completedDestinationsIndices)
                    
                } else {
                    // update
                    let trips = try context.fetch(request)
                    if let tripToUpdate = trips.first {
                        tripToUpdate.removeFromDestinations(tripToUpdate.destinations ?? [])
                        tripToUpdate.removeFromRoutes(tripToUpdate.routes ?? [])
                        tripToUpdate.removeFromRemainingSteps(tripToUpdate.remainingSteps ?? [])
                        
                        
                        for route in trip.routes {
                            let routeContext = CDRoute(context: context)
                            
                            let locale = Locale.current
                            let usesMetric = locale.usesMetricSystem
                            let distance = usesMetric ? route.distance : (route.distance / 0.000621371)
                            
                            routeContext.id = route.id
                            routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                            routeContext.collectionID = route.collectionID
                            routeContext.trip = tripToUpdate
                            routeContext.distanceInMeters = distance
                            routeContext.travelTime = route.travelTime
                            
                            let polylineContext = CDPolyline(context: context)
                            
                            for point in route.polyline?.pts ?? [] {
                                let pointContext = CDPoint(context: context)
                                pointContext.index = Int32(point.index ?? 0)
                                pointContext.latitude = point.latitude ?? 0
                                pointContext.longitude = point.longitude ?? 0
                                pointContext.polyline = polylineContext
                                polylineContext.addToPoints(pointContext)
                            }
                            
                            polylineContext.routeID = route.id
                            routeContext.polyline = polylineContext
                            
                            for step in route.steps {
                                let stepContext = CDStep(context: context)
                                stepContext.id = step.id ?? 0
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
                            destContext.position = Int16(dest.position)
                            tripToUpdate.addToDestinations(destContext)
                        }
                        
                        
                        let startContext = CDDestination(context: context)
                        let tripStart = trip.startLocation
                        startContext.lat = tripStart.lat
                        startContext.lon = tripStart.lon
                        startContext.id = tripStart.id
                        startContext.name = tripStart.name
                        startContext.address = tripStart.address
                        tripToUpdate.startPoint = startContext
                        
                        let endContext = CDDestination(context: context)
                        let tripEnd = trip.endLocation
                        endContext.id = tripEnd.id
                        endContext.name = tripEnd.name
                        endContext.address = tripEnd.address
                        endContext.lat = tripEnd.lat
                        endContext.lon = tripEnd.lon
                        tripToUpdate.endPoint = endContext
                        
                        for remainingStep in trip.remainingSteps {
                            let remStepContext = CDStep(context: context)
                            remStepContext.id = remainingStep.id ?? 0
                            remStepContext.instructions = remainingStep.instructions
                            remStepContext.longitude = remainingStep.longitude ?? 0
                            remStepContext.latitude = remainingStep.latitude ?? 0
                            remStepContext.distance = remainingStep.distanceInMeters ?? 0
                            tripToUpdate.addToRemainingSteps(remStepContext)
                        }
                        
                        tripToUpdate.completedStepCount = trip.completedStepCount
                        tripToUpdate.totalStepCount = trip.totalStepCount
                        tripToUpdate.currentStepIndex = trip.currentStepIndex
                        tripToUpdate.tripState = trip.tripState.rawValue
                        
                        tripToUpdate.nextDestinationIndex = Int16(trip.nextDestinationIndex ?? 0)
                        tripToUpdate.currentRouteIndex = Int16(trip.currentRouteIndex ?? 0)
                        tripToUpdate.remainingDestinationsIndices = NSSet(array: trip.remainingDestinationsIndices)
                        tripToUpdate.completedDestinationsIndices = NSSet(array: trip.completedDestinationsIndices)
                    }
                    
                    
                }
                
                self.save(context) { error in
                    if let error = error {
                        print("Error saving to core data: \(error.localizedDescription)")
                        self.errorManager.message = "Failed to save your trip. Please try again or contact support."
                        self.errorManager.shouldDisplay = true
                    }
                }
                
            } catch {
                print("Error saving context \(error)")
                self.errorManager.message = "Failed to save your trip. Please try again or contact support."
                self.errorManager.shouldDisplay = true
            }
        }
    }
    
    
    func activeTrip(completion: @escaping(Trip?) -> Void, onError: @escaping(Error) -> Void) {
        let context = backgroundContext
        
        do {
            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
            let trips = try context.fetch(request)
            
            if let cdTrip = trips.last {
                completion(Trip(cdTrip))
            } else {
                completion(nil)
            }
        } catch {
            print("Error fetching request: \(error)")
            self.errorManager.message = "Failed to fetch your stored trip. Please try again or contact support."
            self.errorManager.shouldDisplay = true
            onError(error)
        }
    }
}
