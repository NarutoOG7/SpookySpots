//
//  MapForNavigation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import SwiftUI
import MapKit

struct MapForNavigation: UIViewRepresentable {
    
    @ObservedObject var navigationLogic = NavigationLogic.instance
    
    @ObservedObject var userStore = UserStore.instance
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.setRegion(navigationLogic.mapRegion, animated: true)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        addRoute(to: mapView)
        addPlacemarks(to: mapView)
        addCurrentLocation(to: mapView)
    }
    
    func addRoute(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
         
        if let route = navigationLogic.route {
            let polyline = route.polyline
            let mapRect = polyline.boundingMapRect
            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
            view.addOverlay(polyline)
        }
    }
    
    func addPlacemarks(to view: MKMapView) {
        let destinations = navigationLogic.destinations
            for destination in destinations {
                let destCLoc = CLLocation(latitude: destination.lat, longitude: destination.lon)
                let placemark = MKPlacemark(coordinate: destCLoc.coordinate)
                view.addAnnotation(placemark)
        }
    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            view.addAnnotation(MKPlacemark(coordinate: currentLocation.coordinate))
        }
    }
}
