//
//  Route.swift
//  SpookySpots
//
//  Created by Spencer Belton on 7/25/22.
//

import Foundation
import MapKit

struct Route: Identifiable, Equatable {
    let id: String
    let rt: MKRoute
    let collectionID: String
    var polyline: RoutePolyline
    let altPosition: Int
    var tripPosition: Int?
    
    init(dict: [String:AnyObject]) {
        self.id = dict["id"] as? String ?? ""
        self.rt = dict["mkroute"] as? MKRoute ?? MKRoute()
        self.collectionID = dict["collectionID"] as? String ?? ""
        self.polyline = dict["polyline"] as? RoutePolyline ?? RoutePolyline()
        self.altPosition = dict["altPosition"] as? Int ?? 0
        self.tripPosition = dict["tripPosition"] as? Int ?? 0
    }
    //MARK: - Init from Code
    init(id: String,
         rt: MKRoute,
         collectionID: String,
         polyline: RoutePolyline,
         altPosition: Int,
         tripPosition: Int?) {
        self.id = id
        self.rt = rt
        self.collectionID = collectionID
        self.polyline = polyline
        self.altPosition = altPosition
        self.tripPosition = tripPosition
    }
    
}
