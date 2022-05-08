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
    var name: String
    var destinations: [Destination]
    var startLocation: Destination
    var endLocation: Destination
    
    //MARK: - Init from Firebase
    init(dict: [String:AnyObject]) {
        self.id = dict["id"] as? String ?? ""
        self.userID = dict["userID"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        
        self.destinations = []
        
        if let destinations = dict["destinations"] as? [[String:AnyObject]] {
            for destination in destinations {
                let dest = Destination(dict: destination)
                self.destinations.append(dest)
                
            }
        } else {
            self.destinations = []
        }
        
        if let start = dict["startLocation"] as? [String:AnyObject] {
            let startLocation = Destination(dict: start)
            self.startLocation = startLocation
        } else {
            self.startLocation = Destination(dict: [:])
        }
        
        if let end = dict["endLocation"] as? [String:AnyObject] {
            let endLocation = Destination(dict: end)
            self.endLocation = endLocation
        } else {
            self.endLocation = Destination(dict: [:])
        }
    }
    
    //MARK: - Equatable
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
}

//MARK: - Destination
struct Destination: Equatable {
    var lat: Double
    var lon: Double
    var name: String
    
    init(dict: [String:AnyObject]) {
        self.lat = dict["lat"] as? Double ?? 0
        self.lon = dict["lon"] as? Double ?? 0
        self.name = dict["name"] as? String ?? ""
    }
    //MARK: - Init From LocationModel
    init(lat: Double,
         lon: Double,
         name: String) {
        self.lat = lat
        self.lon = lon
        self.name = name
    }
}

