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
    var destinations: [Destination] {
        willSet {
            getRoutes()
        }
    }
    var startLocation: Destination
    var endLocation: Destination
    
    var routes: [Route] {
        willSet {
            self.assignRemainingSteps()
        }
    }
    
    
    var remainingSteps: [Route.Step]
    var completedStepCount: Int16
    var totalStepCount: Int16
    var currentStepIndex: Int16
    
    var tripState: TripState
    
    var nextDestinationIndex: Int?
    var currentRouteIndex: Int?
    
    var completedDestinationsIndices: [Int] = []
    var remainingDestinationsIndices: [Int] = []
    
    
    var totalTimeInSeconds: Double {
        get {
            var time: Double = 0
            for route in routes {
                time += route.travelTime
            }
            return time
        }
    }
    
    var totalDistanceInMeters: Double {
        get {
            var distance: Double = 0
            for route in routes {
                distance += route.distance
            }
            return distance
        }
    }
    
    mutating func getRoutes() {
        self.routes = []
        DispatchQueue.main.async {
            TripLogic.instance.getRoutes()
        }
    }
    
    //MARK: - Init from Code
    init(id: String = "",
         userID: String = "",
         destinations: [Destination] = [],
         startLocation: Destination = Destination(),
         endLocation: Destination = Destination(),
         routes: [Route] = [],
         remainingSteps: [Route.Step],
         completedStepCount: Int16,
         totalStepCount: Int16,
         currentStepIndex: Int16,
         tripState: TripState) {
        
        self.id = id
        self.userID = userID
        self.destinations = destinations
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.routes = routes
        self.remainingSteps = remainingSteps
        self.completedStepCount = completedStepCount
        self.totalStepCount = totalStepCount
        self.currentStepIndex = currentStepIndex
        self.tripState = tripState
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
                                              name: cdDest.name ?? "",
                                              position: Int(cdDest.position))
                destinations.append(destination)
            }
        }
        
        var start = Destination()
        if let cdStart = cdTrip.startPoint {
            start = Destination(id: cdStart.id ?? "",
                                lat: cdStart.lat,
                                lon: cdStart.lon,
                                address: cdStart.address ?? "",
                                name: cdStart.name ?? "",
                                position: Int(cdStart.position))
        }
        
        var end = Destination()
        if let cdEnd = cdTrip.endPoint {
            end = Destination(id: cdEnd.id ?? "",
                              lat: cdEnd.lat,
                              lon: cdEnd.lon,
                              address: cdEnd.address ?? "",
                              name: cdEnd.name ?? "",
                              position: Int(cdEnd.position))
        }
        
        var routes: [Route] = []
        if let cdRoutes = cdTrip.routes?.allObjects as? [CDRoute] {
            for cdRoute in cdRoutes {
                
                let routeID = cdRoute.id ?? ""
                
                var steps = [Route.Step]()
                if let cdSteps = cdRoute.steps?.allObjects as? [CDStep] {
                    for step in cdSteps {
                        let step = Route.Step(id: step.id,
                                              distanceInMeters: step.distance,
                                              instructions: step.instructions,
                                              latitude: step.latitude,
                                              longitude: step.longitude)
                        steps.append(step)
                    }
                }
                
                
                
                if let cdPolyline = cdRoute.polyline {
                    var points = [Route.Point]()
                    var coordinates = [CLLocationCoordinate2D]()
                    if let cdPoints = cdPolyline.points?.allObjects as? [CDPoint] {
                        for cdPoint in cdPoints.sorted(by: { $0.index < $1.index }) {
                            let point = Route.Point(index: Int(cdPoint.index),
                                                    latitude: cdPoint.latitude,
                                                    longitude: cdPoint.longitude)
                            points.append(point)
                            
                            let coordinate = CLLocationCoordinate2D(
                                latitude: cdPoint.latitude,
                                longitude: cdPoint.longitude)
                            coordinates.append(coordinate)
                        }
                    }
                    
                    
                    let poly = RoutePolyline(coordinates: coordinates, count: coordinates.count)
                    poly.parentCollectionID = end.id
                    poly.startLocation = start
                    poly.endLocation = end
                    poly.pts = points.sorted(by: { $0.index ?? 0 < $1.index ?? 1 })
                    poly.routeID = routeID
                    
                    let locale = Locale.current
                    let usesMetric = locale.usesMetricSystem
                    let distance = usesMetric ? cdRoute.distanceInMeters : (cdRoute.distanceInMeters * 0.000621371)
                    
                    let route = Route(id: routeID,
                                      steps: steps,
                                      travelTime: cdRoute.travelTime,
                                      distance: distance,
                                      collectionID: cdRoute.collectionID ?? "",
                                      polyline: poly,
                                      altPosition: 0,
                                      tripPosition: Int(cdRoute.tripPosition))
                    
                    routes.append(route)
                }
            }
        }
        
        var remainigSteps: [Route.Step] = []
        if let cdRemainigSteps = cdTrip.remainingSteps?.allObjects as? [CDStep] {
            for cdStep in cdRemainigSteps {
                let step = Route.Step(id: cdStep.id,
                                      distanceInMeters: cdStep.distance,
                                      instructions: cdStep.instructions,
                                      latitude: cdStep.latitude,
                                      longitude: cdStep.longitude)
                remainigSteps.append(step)
            }
        }
        
        print(routes.count)
        
        self.id = cdTrip.id ?? ""
        self.userID = cdTrip.userID ?? ""
        self.destinations = destinations
        self.startLocation = start
        self.endLocation = end
        self.routes = routes
        
        self.remainingSteps = remainigSteps
        self.completedStepCount = cdTrip.completedStepCount
        self.totalStepCount = cdTrip.totalStepCount
        self.currentStepIndex = cdTrip.currentStepIndex
        
        let state = stateForString(cdTrip.tripState ?? "")
        self.tripState = state
        
        self.completedDestinationsIndices = cdTrip.completedDestinationsIndices as? [Int] ?? []
        self.remainingDestinationsIndices = cdTrip.remainingDestinationsIndices as? [Int] ?? []
        self.nextDestinationIndex = Int(cdTrip.nextDestinationIndex)
        self.currentRouteIndex = Int(cdTrip.currentRouteIndex)
        
        func stateForString(_ string: String) -> TripState {
            switch string {
            case "building":
                return .building
            case "navigating":
                return .navigating
            case "paused":
                return .paused
            case "finished":
                return .finished
            default:
                return .building
            }
        }
        
    }
    
    mutating func assignRemainingSteps() {
        var steps = [Route.Step]()
        for route in self.routes {
            for step in route.steps.sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) {
                steps.append(step)
            }
        }
        self.remainingSteps = steps
    }
    
    
    //MARK: - Equatable
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
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
