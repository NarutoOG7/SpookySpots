//
//  Route.swift
//  SpookySpots
//
//  Created by Spencer Belton on 7/25/22.
//

import SwiftUI
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
        var id: Int16?
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


class RoutePolyline: MKPolyline, Identifiable {
    var id = UUID()
    var parentCollectionID: String?
    var color: Color?
    var startLocation: Destination?
    var endLocation: Destination?
    var pts: [Route.Point]?
    var routeID: String?
    
    func setPointCoordinates(_ rt: MKRoute) {
        pointsFromUnsafePointer(rt: rt) { points in
            self.pts = points
        }
    }
    
    func pointsFromUnsafePointer(rt: MKRoute, completion: @escaping([Route.Point]) -> (Void)) {
        var index = 0
        var points = [Route.Point]()
        for pt in UnsafeBufferPointer(start: rt.polyline.points(),
                                      count: rt.polyline.pointCount) {

            let point = Route.Point(index: index,
                                    latitude: pt.coordinate.latitude,
                                    longitude: pt.coordinate.longitude)
            index += 1
            points.append(point)
        }
        completion(points)
    }
}
