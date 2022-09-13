//
//  Route.swift
//  SpookySpots
//
//  Created by Spencer Belton on 7/25/22.
//

import Foundation
import MapKit

struct Route: Identifiable, Equatable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let steps: [Step]
    let travelTime: Double
    let distance: Double
    let collectionID: String
    let altPosition: Int
    var tripPosition: Int?
//    var polyline: MKPolyline?
    var polyline: RoutePolyline?
    
    //MARK: - Init from Code
    init(id: String = "",
         steps: [Step] = [Step](),
         travelTime: Double = 0,
         distance: Double = 0,
         collectionID: String = "",
//         polyline: MKPolyline? = nil,
         polyline: RoutePolyline? = nil,
         altPosition: Int = 0,
         tripPosition: Int? = 0) {
        self.id = id
        self.steps = steps
        self.travelTime = travelTime
        self.distance = distance
        self.collectionID = collectionID
        self.polyline = polyline
        self.altPosition = altPosition
        self.tripPosition = tripPosition
    }
    
    //MARK: - Step
    struct Step: Equatable, Hashable {
        var distanceInMeters: Double?
        var instructions: String?
        var latitude: Double?
        var longitude: Double?
    }
    
    //MARK: - Point
    struct Point: Equatable {
        var index: Int?
        var latitude: Double?
        var longitude: Double?
    }
}

