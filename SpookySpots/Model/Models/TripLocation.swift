//
//  TripLocation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import Foundation
import CoreLocation

struct TripTwo: Equatable, Identifiable {

    
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
        
    }
    
    //MARK: - Equatable
    static func == (lhs: TripTwo, rhs: TripTwo) -> Bool {
        lhs.id == rhs.id
    }
    
    //MARK: - Destination
    struct Destination {
        var lat: Double
        var lon: Double
        var name: String
    }
}

