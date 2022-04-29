//
//  TripLocation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import Foundation
import CoreLocation

struct TripLocation: Equatable, Identifiable {
    var id: String = ""
    var name: String = ""
    var cLLocation = CLLocation()
    var location: LocationData?
}
