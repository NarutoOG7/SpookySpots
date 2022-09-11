//
//  TripLocation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import Foundation
import CoreLocation
import CloudKit
import MapKit

struct Trip: Equatable, Identifiable {
    
    var id: String
    var userID: String
    var isActive: Bool
    var destinations: [Destination]
    var startLocation: Destination
    var endLocation: Destination
    var routes: [Route]
    
    var nextDestination: Destination?
    var recentlyCompletedDestination: Destination?
    var completedDestinations: [Destination] = []
    var remainingDestinations: [Destination] = []
    
     
    //MARK: - Init from Code
    init(id: String = "",
         userID: String = "",
         isActive: Bool = true,
         destinations: [Destination] = [],
         startLocation: Destination = Destination(),
         endLocation: Destination = Destination(),
         routes: [Route] = []) {
        
        self.id = id
        self.userID = userID
        self.isActive = isActive
        self.destinations = destinations
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.routes = routes
    }
    
    //MARK: - Init From CoreDataTrip
    init(_ cdTrip: CDTrip) {
        
        var destinations: [Destination] = []
        if let cdDests = cdTrip.destinations?.allObjects as? [CDDestination] {
            for cdDest in cdDests {
                let destination = Destination(id: cdDest.id ?? "",
                                              lat: cdDest.lat,
                                              lon: cdDest.lon,
                                              address: cdDest.address ?? "",
                                              name: cdDest.name ?? "")
                destinations.append(destination)
            }
        }
        
        var remainingDests: [Destination] = []
        if let cdRemainingDests = cdTrip.remainingDestinations?.allObjects as? [CDDestination] {
            for cdDest in cdRemainingDests {
                let remainingDest = Destination(id: cdDest.id ?? "",
                                                lat: cdDest.lat,
                                                lon: cdDest.lon,
                                                address: cdDest.address ?? "",
                                                name: cdDest.name ?? "")
                remainingDests.append(remainingDest)
            }
        }
        
        var completedDests: [Destination] = []
        if let cdCompletedDests = cdTrip.completedDestinations?.allObjects as? [CDDestination] {
            for cdDest in cdCompletedDests {
                let completedDest = Destination(id: cdDest.id ?? "",
                                                lat: cdDest.lat,
                                                lon: cdDest.lon,
                                                address: cdDest.address ?? "",
                                                name: cdDest.name ?? "")
                completedDests.append(completedDest)
            }
        }
        
        
        var start = Destination()
        if let cdStart = cdTrip.startPoint {
            start = Destination(id: cdStart.id ?? "",
                                lat: cdStart.lat,
                                lon: cdStart.lon,
                                address: cdStart.address ?? "",
                                name: cdStart.name ?? "")
        }
        
        var end = Destination()
        if let cdEnd = cdTrip.endPoint {
            end = Destination(id: cdEnd.id ?? "",
                              lat: cdEnd.lat,
                              lon: cdEnd.lon,
                              address: cdEnd.address ?? "",
                              name: cdEnd.name ?? "")
        }

        var nextDest = Destination()
        if let cdNextDest = cdTrip.nextDestination {
            nextDest = Destination(id: cdNextDest.id ?? "",
                                   lat: cdNextDest.lat,
                                   lon: cdNextDest.lon,
                                   address: cdNextDest.address ?? "",
                                   name: cdNextDest.name ?? "")
        }
        
        var recentCompletedDest = Destination()
        if let cdRecentCompleteDest = cdTrip.recentlyCompletedDestination {
            recentCompletedDest = Destination(id: cdRecentCompleteDest.id ?? "",
                                              lat: cdRecentCompleteDest.lat,
                                              lon: cdRecentCompleteDest.lon,
                                              address: cdRecentCompleteDest.address ?? "",
                                              name: cdRecentCompleteDest.name ?? "")
        }
        
        var routes: [Route] = []
        if let cdRoutes = cdTrip.routes?.allObjects as? [CDRoute] {
            for cdRoute in cdRoutes {
                
                var steps = [Route.Step]()
                if let cdSteps = cdRoute.steps?.allObjects as? [CDStep] {
                    for step in cdSteps {
                        let step = Route.Step(distanceInMeters: step.distance,
                                              instructions: step.instructions,
                                              latitude: step.latitude,
                                              longitude: step.longitude)
                        steps.append(step)
                    }
                }
                
                var route = Route(id: cdRoute.id ?? "",
                                  steps: steps,
                                  travelTime: cdRoute.travelTime,
                                  distance: cdRoute.distance,
                                  collectionID: cdRoute.collectionID ?? "",
                                  altPosition: 0,
                                  tripPosition: Int(cdRoute.tripPosition))
                
                if let cdPolyline = cdRoute.polyline {
                    var points = [Route.Point]()
                    var coordinates = [CLLocationCoordinate2D]()
                    var mkPoints = [MKMapPoint]()
                    if let cdPoints = cdPolyline.points?.allObjects as? [CDPoint] {
                        for cdPoint in cdPoints {
                            let point = Route.Point(x: cdPoint.x,
                                                    y: cdPoint.y,
                                                    latitude: cdPoint.latitude,
                                                    longitude: cdPoint.longitude)
                            points.append(point)
                            
                            let mkPoint = MKMapPoint(x: cdPoint.x, y: cdPoint.y)
                            mkPoints.append(mkPoint)
                            
                            let coordinate = CLLocationCoordinate2D(
                                latitude: cdPoint.latitude,
                                longitude: cdPoint.longitude)
                            coordinates.append(coordinate)
                        }
                    }
                    
//                    let poly = RoutePolyline(coordinates: coordinates,
//                                             count: coordinates.count)
                    let poly = RoutePolyline(points: mkPoints, count: mkPoints.count)
                    poly.parentCollectionID = end.id
                    poly.startLocation = start
                    poly.endLocation = end
                    poly.pts = points
                    
                    // Thes make sure that the updated version of polyline and route is used
                    route.polyline = poly
                    poly.route = route
                    route.polyline = poly
                    poly.route = route
                    
//                    polyline = RoutePolyline(parentCollectionID: end.id,
//                                             color: K.Colors.WeenyWitch.orange,
//                                             route: route,
//                                             startLocation: start,
//                                             endLocation: end,
//                                             pts: points)
                }
                routes.append(route)
            }
        }
        
//        var routes: [Route] = []
//        if let cdRoutes = cdTrip.routes?.allObjects as? [CDRoute] {
//            for cdRoute in cdRoutes {
//                if let cdMKRoute = cdRoute.mkRoute {
//                    var mkRoute = MKRoute()
//
//                    switch cdRoute.tripPosition {
//                    case 0:
//                        if let end = destinations.first {
//                        getSpecificRouteMatching(name: cdMKRoute.name ?? "", distance: cdMKRoute.distance, duration: cdMKRoute.expectedTravelTime, start: start, end: end, withCompletion: { route in
//                            mkRoute = route
//                        })
//                        }
//                    default:
//                        let start = destinations[Int(cdRoute.tripPosition) - 1]
//                        let end = destinations[Int(cdRoute.tripPosition)]
//                        getSpecificRouteMatching(name: cdMKRoute.name ?? "", distance: cdMKRoute.distance, duration: cdMKRoute.expectedTravelTime, start: start, end: end) { route in
//                            mkRoute = route
//                        }
//                    }
//
//                    let route = Route(id: cdRoute.id ?? "",
//                                      rt: MKRoute(),
//                                      collectionID: cdRoute.collectionID ?? "",
//                                      polyline: RoutePolyline(),
//                                      altPosition: 0,
//                                      tripPosition: Int(cdRoute.tripPosition) )
//                    routes.append(route)
//                }
//            }
//        }
        

        self.id = cdTrip.id ?? ""
        self.userID = cdTrip.userID ?? ""
        self.isActive = cdTrip.isActive
        self.destinations = destinations
        self.startLocation = start
        self.endLocation = end
        self.routes = routes
        
        self.completedDestinations = completedDests
        self.remainingDestinations = remainingDests
        self.nextDestination = nextDest
        self.recentlyCompletedDestination = recentCompletedDest
        
    }
    
    //MARK: - Equatable
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
  
}

enum TripDetails: String {
    case startingLocationID = "StartID123"
    case endLocationID = "EndID123"
}

//MARK: - DirectionsRequest to get specific Route upon init
private func getSpecificRouteMatching(name: String, distance: Double, duration: Double, start: Destination, end: Destination,
                                   withCompletion completion: @escaping(MKRoute) -> (Void)) {
    let request = MKDirections.Request()
    request.transportType = .automobile
    request.requestsAlternateRoutes = true
    
    let mapItemA = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: start.lat, longitude: start.lon))
    let mapItemB = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end.lat, longitude: end.lon))
    
    request.source = MKMapItem(placemark: mapItemA)
    request.destination = MKMapItem(placemark: mapItemB)
    
    let directions = MKDirections(request: request)
    directions.calculate { response, error in
        if let error = error {
            print(error.localizedDescription)
        }
        guard let response = response else { return }

        for rt in response.routes.prefix(3) {
            if rt.name == name &&
                rt.distance == CLLocationDistance(distance) &&
                rt.expectedTravelTime == TimeInterval(duration) {
        
                                        completion(rt)
            }
        }
        
    }
}

//MARK: - Init From Firebase ? Future ?
/*
 
 init(dict: [String:AnyObject]) {
     
     self.id = dict["id"] as? String ?? ""
     
     self.userID = dict["userID"] as? String ?? ""
     
     self.isActive = dict["isActive"] as? Bool ?? false

     self.destinations = []
     self.startLocation = Destination(dict: [:])
     self.endLocation = Destination(dict: [:])
     self.routes = []
     
     setDestinations(dict: dict)
     setStartLoc(dict: dict)
     setEndLoc(dict: dict)
     setRoutes(dict: dict)
 }
 
 mutating func setDestinations(dict: [String:AnyObject]) {
     if let destinations = dict["destinations"] as? [[String:AnyObject]] {
         for destination in destinations {
             let dest = Destination(dict: destination)
             self.destinations.append(dest)
         }
     } else {
         self.destinations = []
     }
 }
 
 mutating func setStartLoc(dict: [String:AnyObject]) {
     if let start = dict["startLocation"] as? [String:AnyObject] {
         let startLocation = Destination(dict: start)
         self.startLocation = startLocation
     } else {
         self.startLocation = Destination(dict: [:])
     }
 }
 
 mutating func setEndLoc(dict: [String:AnyObject]) {
     if let end = dict["endLocation"] as? [String:AnyObject] {
         let endLocation = Destination(dict: end)
         self.endLocation = endLocation
     } else {
         self.endLocation = Destination(dict: [:])
     }
 }
 
 mutating func setRoutes(dict: [String:AnyObject]) {
     if let routes = dict["routes"] as? [[String:AnyObject]] {
         for route in routes {
             let rt = Route(dict: route)
             self.routes.append(rt)
         }
     }
 }
 
 */
