//
//  Destination.swift
//  SpookySpots
//
//  Created by Spencer Belton on 6/22/22.
//

import Foundation
import CoreLocation

struct Destination: Codable, Equatable, Identifiable {
    var id: String
    var lat: Double
    var lon: Double
    var address: String
    var name: String
    var index: Int
    
    init(dict: [String:AnyObject]) {
        self.id = dict["id"] as? String ?? ""
        self.lat = dict["lat"] as? Double ?? 0
        self.lon = dict["lon"] as? Double ?? 0
        self.address = dict["address"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.index = dict["index"] as? Int ?? 0
    }
    //MARK: - Init From LocationModel
    init(id: String = "",
         lat: Double = -105,
         lon: Double = 39,
         address: String = "",
         name: String = "",
         index: Int = 0) {
        self.id = id
        self.lat = lat
        self.lon = lon
        self.address = address
        self.name = name
        self.index = index
    }
    
    static let base = Destination(id: "BASE", lat: 39.5501, lon: -105.7821, address: "", name: "BASE", index: 0)
}
