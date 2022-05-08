////
////  MapForTrip.swift
////  SpookySpots
////
////  Created by Spencer Belton on 3/24/22.
////
//
//import SwiftUI
//import MapKit
//
//
//struct MapForTrip: UIViewRepresentable {
//
//    let mapViewDelegate = MapViewDelegate()
//
//    @ObservedObject var userStore = UserStore.instance
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.setRegion(tripPageVM.mapRegion, animated: true)
//        mapView.addAnnotations(tripPageVM.tripLocationsForAnnotations)
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.delegate = mapViewDelegate
//        uiView.translatesAutoresizingMaskIntoConstraints = false
//        addRoute(to: uiView)
//        addPlacemarks(to: uiView)
//        addCurrentLocation(to: uiView)
//    }
//
//    func addRoute(to view: MKMapView) {
//        if !view.overlays.isEmpty {
//            view.removeOverlays(view.overlays)
//        }
//
//        for route in tripPageVM.routes {
//            let polyline = route.polyline
//            let mapRect = polyline.boundingMapRect
//            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
//            view.addOverlay(polyline)
//        }
//    }
//
//    func addCurrentLocation(to view: MKMapView) {
//        if let currentLocation = userStore.currentLocation {
//            view.addAnnotation(
//                MKPlacemark(coordinate: currentLocation.coordinate))
//
//        }
//    }
//    
//    func addPlacemarks(to view: MKMapView) {
//        let locations = tripPageVM.trip.locations
//        for location in locations {
//            let placemark = MKPlacemark(coordinate: location.cLLocation.coordinate)
//            view.addAnnotation(placemark)
//        }
//    }
//}
//
//
////MARK: - MapViewDelegate
//
//class MapViewDelegate: NSObject, MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.fillColor = UIColor.blue.withAlphaComponent(0.75)
//        renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
//        return renderer
//    }
//}
