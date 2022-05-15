//
//  MapForNavigation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import SwiftUI
import MapKit

struct MapForNavigation: UIViewRepresentable {
    
    @StateObject var navigationLogic = NavigationLogic.instance
    
    @ObservedObject var userStore = UserStore.instance
    
    func makeUIView(context: Context) -> some MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(navigationLogic.mapRegion, animated: true)
        mapView.addAnnotations(navigationLogic.destAnnotations)
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        addRoute(to: uiView)
        addPlacemarks(to: uiView)
        addCurrentLocation(to: uiView)
    }
    
    func addRoute(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        let route = navigationLogic.route
            let polyline = route.polyline
            let mapRect = polyline.boundingMapRect
            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
            view.addOverlay(polyline)
        
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
