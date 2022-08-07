//
//  TripLocation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import Foundation
import CoreLocation
import CloudKit

struct Trip: Equatable, Identifiable {
    
    var id: String
    var userID: String
    var isActive: Bool
    var destinations: [Destination]
    var startLocation: Destination
    var endLocation: Destination
    var routes: [Route]
    
    //MARK: - Init from Firebase
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
    
    //MARK: - Equatable
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
}

enum TripDetails: String {
    case startingLocationID = "StartID123"
    case endLocationID = "EndID123"
}

