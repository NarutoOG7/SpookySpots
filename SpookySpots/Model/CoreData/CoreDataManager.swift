////
////  CoreDataManager.swift
////  SpookySpots
////
////  Created by Spencer Belton on 7/28/22.
////
//
//import CoreData
//import SwiftUI
//
//class CoreDataManager: ObservableObject {
//    static let instance = CoreDataManager()
//    
////    let currentTripContainer = NSPersistentContainer(name: "TripCDModel")
//    
//     var context: NSManagedObjectContext {
//          return persistentContainer.viewContext
//      }
//      
//       var persistentContainer: NSPersistentContainer = {
//          let container = NSPersistentContainer(name: "TripCDModel")
//          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//              if let error = error as NSError? {
//                  fatalError("Unresolved error \(error), \(error.userInfo)")
//              }
//          })
//          return container
//      }()
//        
//
//    //    @ObservedObject var tripLogic = TripLogic.instance
//    
////    var context = currentTripContainer.viewContext
//
//    
////    init() {
////        persistentContainer.loadPersistentStores { description, error in
////            if let error = error {
////                print("Core Data failed to load: \(error.localizedDescription)")
////            }
////        }
////    }
//    
//    func saveTripAsCDTrip(trip: Trip) {
//        
//            
//   
////        do {
//            let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", trip.id)
////              let numberOfRecords = try context.count(for: request)
////              if numberOfRecords == 0 {
////                  let newFav = CDTrip(context: context)
////                  newFav.name = name
////                  newFav.id = id
////                  try context.save()
////              } else {
////                  // update
////                  var tripToUpdate = reque
////              }
////          } catch {
////              print("Error saving context \(error)")
////          }
//        let cdTrip = CDTrip(context: context)
////
////
//            //        var cdRoutes: [CDRoute] = []
//            for route in trip.routes {
//                let routeContext = CDRoute(context: context)
//                routeContext.id = route.id
//                routeContext.tripPosition = Int16(route.tripPosition ?? 0)
//                routeContext.collectionID = route.collectionID
//                routeContext.rtName = route.rt.name
//                routeContext.trip = cdTrip
//                cdTrip.addToRoutes(routeContext)
//                
//                //            cdRoutes.append(routeContext)
//            }
//            
//            //        var cdDestinations: [CDDestination] = []
//            for dest in trip.destinations {
//                let destContext = CDDestination(context: context)
//                destContext.id = dest.id
//                destContext.lon = dest.lon
//                destContext.lat = dest.lat
//                destContext.name = dest.name
//                destContext.trip = cdTrip
//                cdTrip.addToDestinations(destContext)
//                //            cdDestinations.append(destContext)
//            }
//            
//            //        var cdEndPoints: [CDDestination] = []
//            
//            let startContext = CDEndPoint(context: context)
//            let tripStart = trip.startLocation
//            startContext.position = 0
//            let startDestContext = CDDestination(context: context)
//            startDestContext.lat = tripStart.lat
//            startDestContext.lon = tripStart.lon
//            startDestContext.id = tripStart.id
//            startDestContext.name = tripStart.name
//            startDestContext.trip = cdTrip
//            startContext.destination = startDestContext
//            cdTrip.addToEndPoints(startContext)
//            //        cdEndPoints.append(startContext)
//            
//            let endContext = CDEndPoint(context: context)
//            let tripEnd = trip.endLocation
//            endContext.position = 1
//            let endDestContext = CDDestination(context: context)
//            endDestContext.id = tripEnd.id
//            endDestContext.name = tripEnd.name
//            endDestContext.lat = tripEnd.lat
//            endDestContext.lon = tripEnd.lon
//            endDestContext.trip = cdTrip
//            endContext.destination = endDestContext
//            cdTrip.addToEndPoints(endContext)
//            //        cdEndPoints.append(endContext)
//            
//            
//            cdTrip.id = trip.id
//            //        cdTrip.routes = NSSet(array: cdRoutes)
//            //        cdTrip.endPoints = NSSet(array: cdEndPoints)
//            //        cdTrip.destinations = NSSet(array: cdDestinations)
//            cdTrip.isActive = trip.isActive
//            cdTrip.userID = UserStore.instance.user.id
//        
//        
//        do {
//         let fetchResults = try context.fetch(request)
//            
//            if fetchResults.count != 0 {
//                // update
//                let managedObject = fetchResults[0]
////                managedObject.setValuesForKeys([
////                    "id" : cdTrip.id,
////                    "isActive" : cdTrip.isActive,
////                    "userID" : cdTrip.userID
////
////                ])
//                
//                try managedObject.managedObjectContext?.save()
//            } else {
//                //insert as new data
//                let newObject = cdTrip
//                
//                try newObject.managedObjectContext?.save()
//            }
//        } catch {
//            print("Error saving context \(error)")
//
//        }
//        
//        
//            
////            do {
////                try context.save()
////            } catch {
////                print(error.localizedDescription)
////            }
//            
//    
//    }
//    
//    
//    func fetchCDTrip(_ trip: Trip) -> CDTrip {
//        let request : NSFetchRequest<CDTrip> = CDTrip.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", trip.id)
//        do {
//        
//                let fetchResults = try context.fetch(request)
//                if fetchResults.count != 0 {
//                    return fetchResults[0]
//                
//            }
//        } catch {
//            print("Error with fetch core data object: \(error.localizedDescription)")
//        }
//        return CDTrip()
//    }
//}
