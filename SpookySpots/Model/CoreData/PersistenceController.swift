//
//  PersistenceController.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/7/22.
//

import CoreData
import MapKit

class PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TripCDModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
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
    
    func createOrUpdateTrip(_ trip: Trip) {
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
                    routeContext.rtName = route.rt.name
                    routeContext.trip = newTrip
                    newTrip.addToRoutes(routeContext)
                    
                    //            cdRoutes.append(routeContext)
                }
                
                //        var cdDestinations: [CDDestination] = []
                for dest in trip.destinations {
                    let destContext = CDDestination(context: context)
                    destContext.id = dest.id
                    destContext.lon = dest.lon
                    destContext.lat = dest.lat
                    destContext.name = dest.name
                    destContext.trip = newTrip
                    newTrip.addToDestinations(destContext)
                    //            cdDestinations.append(destContext)
                }
                
                //        var cdEndPoints: [CDDestination] = []
                
                let startContext = CDEndPoint(context: context)
                let tripStart = trip.startLocation
                startContext.position = 0
                let startDestContext = CDDestination(context: context)
                startDestContext.lat = tripStart.lat
                startDestContext.lon = tripStart.lon
                startDestContext.id = tripStart.id
                startDestContext.name = tripStart.name
                startDestContext.trip = newTrip
                startContext.destination = startDestContext
                newTrip.addToEndPoints(startContext)
                //        cdEndPoints.append(startContext)
                
                let endContext = CDEndPoint(context: context)
                let tripEnd = trip.endLocation
                endContext.position = 1
                let endDestContext = CDDestination(context: context)
                endDestContext.id = tripEnd.id
                endDestContext.name = tripEnd.name
                endDestContext.lat = tripEnd.lat
                endDestContext.lon = tripEnd.lon
                endDestContext.trip = newTrip
                endContext.destination = endDestContext
                newTrip.addToEndPoints(endContext)
                //        cdEndPoints.append(endContext)
                
                
                newTrip.id = trip.id
                //        cdTrip.routes = NSSet(array: cdRoutes)
                //        cdTrip.endPoints = NSSet(array: cdEndPoints)
                //        cdTrip.destinations = NSSet(array: cdDestinations)
                newTrip.isActive = trip.isActive
                newTrip.userID = UserStore.instance.user.id
                
                
                
            } else {
                // update
                let trips = try request.execute()
                if let tripToUpdate = trips.first {
                    for route in trip.routes {
                        let routeContext = CDRoute(context: context)
                        routeContext.id = route.id
                        routeContext.tripPosition = Int16(route.tripPosition ?? 0)
                        routeContext.collectionID = route.collectionID
                        routeContext.rtName = route.rt.name
                        routeContext.trip = tripToUpdate
                        tripToUpdate.addToRoutes(routeContext)
                        
                        //            cdRoutes.append(routeContext)
                    }
                    
                    //        var cdDestinations: [CDDestination] = []
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
                    let startDestContext = CDDestination(context: context)
                    startDestContext.lat = tripStart.lat
                    startDestContext.lon = tripStart.lon
                    startDestContext.id = tripStart.id
                    startDestContext.name = tripStart.name
                    startDestContext.trip = tripToUpdate
                    startContext.destination = startDestContext
                    tripToUpdate.addToEndPoints(startContext)
                    //        cdEndPoints.append(startContext)
                    
                    let endContext = CDEndPoint(context: context)
                    let tripEnd = trip.endLocation
                    endContext.position = 1
                    let endDestContext = CDDestination(context: context)
                    endDestContext.id = tripEnd.id
                    endDestContext.name = tripEnd.name
                    endDestContext.lat = tripEnd.lat
                    endDestContext.lon = tripEnd.lon
                    endDestContext.trip = tripToUpdate
                    endContext.destination = endDestContext
                    tripToUpdate.addToEndPoints(endContext)
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
    
    func cdTripToTrip(_ cdTrip: CDTrip) -> Trip {
        var destinations: [Destination] = []
        if let cdDests = cdTrip.destinations?.allObjects as? [CDDestination] {
            for cdDest in cdDests {
                let destination = Destination(id: cdDest.id ?? "",
                                              lat: cdDest.lat,
                                              lon: cdDest.lon,
                                              name: cdDest.name ?? "")
                destinations.append(destination)
            }
        }
        
        var routes: [Route] = []
        if let cdRoutes = cdTrip.routes?.allObjects as? [CDRoute] {
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
        if let endPoints = cdTrip.endPoints?.allObjects as? [CDEndPoint] {
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
        
        return Trip(id: cdTrip.id ?? "",
                    userID: cdTrip.userID ?? "",
                    isActive: cdTrip.isActive,
                    destinations: destinations,
                    startLocation: start,
                    endLocation: end,
                    routes: routes)
    }
}
