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
    var tripState: TripState
    var destinations: [Destination]
    var startLocation: Destination
    var endLocation: Destination
    
    //MARK: - Init from Firebase
    init(dict: [String:AnyObject]) {
        
        self.id = dict["id"] as? String ?? ""
        
        self.userID = dict["userID"] as? String ?? ""
        
        self.tripState = .finished
        let tripStateString = dict["tripState"] as? String ?? ""

        self.destinations = []
        self.startLocation = Destination(dict: [:])
        self.endLocation = Destination(dict: [:])
        
        setTripState(tripStateString)
        setDestinations(dict: dict)
        setStartLoc(dict: dict)
        setEndLoc(dict: dict)

    }
    
    mutating func setTripState(_ tripStateString: String) {
        switch tripStateString {
        case "creating":
            self.tripState = .creating
        case "readyToDirect":
            self.tripState = .readyToDirect
        case "directing":
            self.tripState = .directing
        case "paused":
            self.tripState = .paused
        case "finished":
            self.tripState = .finished
        default:
            self.tripState = .finished
        }
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
    
    //MARK: - Init from Code
    init(id: String,
         userID: String,
         tripState: TripState,
         destinations: [Destination],
         startLocation: Destination,
         endLocation: Destination) {
        
        self.id = id
        self.userID = userID
        self.tripState = tripState
        self.destinations = destinations
        self.startLocation = startLocation
        self.endLocation = endLocation
    }
    
    //MARK: - Equatable
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
}

//MARK: - Destination
struct Destination: Equatable, Identifiable {
    var id: String
    var lat: Double
    var lon: Double
    var name: String
    
    init(dict: [String:AnyObject]) {
        self.id = dict["id"] as? String ?? ""
        self.lat = dict["lat"] as? Double ?? 0
        self.lon = dict["lon"] as? Double ?? 0
        self.name = dict["name"] as? String ?? ""
    }
    //MARK: - Init From LocationModel
    init(id: String,
         lat: Double,
         lon: Double,
         name: String) {
        self.id = id
        self.lat = lat
        self.lon = lon
        self.name = name
    }
}

