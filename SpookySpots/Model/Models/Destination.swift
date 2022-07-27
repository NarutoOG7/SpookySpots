//
//  Destination.swift
//  SpookySpots
//
//  Created by Spencer Belton on 6/22/22.
//

import Foundation

struct Destination: Codable, Equatable, Identifiable {
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
