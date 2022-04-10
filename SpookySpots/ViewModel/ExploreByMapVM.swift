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
    @Published var region = MKCoordinateRegion(
        center: MapDetails.startingLocation.coordinate,
        span: MapDetails.defaultSpan)
//    {
//        willSet {
//            let newRegionCenter = CLLocation(latitude: newValue.center.latitude,
//                                             longitude: newValue.center.longitude)
//            let oldRegionCenter = CLLocation(latitude: regionBeforeLastMove.center.latitude,
//                                             longitude: regionBeforeLastMove.center.longitude)
//            
//            if oldRegionCenter.distance(from: newRegionCenter) > 1000 {
//                GeoFireManager.instance.searchForLocations(region: newValue)
//            }
//            regionBeforeLastMove = newValue
//        }
//    }
    private var regionBeforeLastMove = MKCoordinateRegion()
    @Published var showingLocationList = false
//    @Published var region = MKCoordinateRegion(
//        center: MapDetails.startingLocation.coordinate,
//        span: MapDetails.defaultSpan) {
//            willSet {
//                let center = newValue.center
//                let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)
//                GeoFireManager.instance.showSpotsOnMap(location: loc) { location in
//                    self.locationStore.onMapLocations.append(location)
//                }
//            }
//        }
    
}


//class RegionWrapper {
//    static let instance = RegionWrapper()
//
//    var _region: MKCoordinateRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 30, longitude: -90),
//        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//
//    var region: Binding<MKCoordinateRegion> {
//        Binding(
//            get: { self._region },
//            set: { self._region = $0 }
//        )
//    }
//}
