//
//  ExploreByMapVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit

class ExploreByMapVM: ObservableObject {
    static let instance = ExploreByMapVM()
    
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var locationStore   = LocationStore.instance
    @ObservedObject var userStore       = UserStore.instance
    
    var selectedLocationDistance: Double = 0
    @Published var locationShownOnList: Location?
    @Published var locAnnoTapped: LocationAnnotationModel?
    @Published var region = MapDetails.defaultRegion

    private var regionBeforeLastMove = MKCoordinateRegion()
    @Published var showingLocationList = false

    
}

