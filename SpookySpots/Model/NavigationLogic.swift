//
//  NavigationLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import Foundation
import MapKit

class NavigationLogic: ObservableObject {
    static let instance = NavigationLogic()
    
    @Published var route = MKRoute()
    @Published var destinations: [Destination] = []
    @Published var destAnnotations: [LocationAnnotationModel] = []
    
    @Published var mapRegion = MKCoordinateRegion()
    
}
