//
//  MapForTrip.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit


struct MapForTrip: UIViewRepresentable {
        
    @ObservedObject var userStore = UserStore.instance
    
    @StateObject var tripLogic = TripLogic.instance
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(tripLogic.mapRegion, animated: true)
        mapView.addAnnotations(tripLogic.destAnnotations)
        
        mapView.delegate = context.coordinator
        
        let mapTap = TapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped(_:)))
        mapTap.map = mapView
        mapView.addGestureRecognizer(mapTap)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = context.coordinator
        uiView.translatesAutoresizingMaskIntoConstraints = false
        addRoute(to: uiView)
        addPlacemarks(to: uiView)
        addCurrentLocation(to: uiView)
    }
    
    func makeCoordinator() -> MapViewDelegate {
        MapViewDelegate(self)
    }
    
    func addTapGestureRecognizer(to view: MKMapView) {
        
    }
    
    func addRoute(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        
        for route in tripLogic.availableRoutes {
            let polyline = RoutePolyline(points: route.rt.polyline.points(), count: route.rt.polyline.pointCount)
            polyline.status = .inactive
            polyline.parentCollectionID = route.collectionID
            
            let mapRect = polyline.boundingMapRect
            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
            view.addOverlay(polyline)
            
        }
        
        for route in tripLogic.chosenRoutes {
            let polyline = RoutePolyline(points: route.rt.polyline.points(), count: route.rt.polyline.pointCount)
            polyline.status = .active
            polyline.parentCollectionID = route.collectionID
            
            let mapRect = polyline.boundingMapRect
            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
            view.addOverlay(polyline)
        }
        
    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            view.addAnnotation(
                MKPlacemark(coordinate: currentLocation.coordinate))
            
        }
    }
    
    func addPlacemarks(to view: MKMapView) {
        if let trip = tripLogic.currentTrip {
            for destination in trip.destinations {
                let destCLoc = CLLocation(latitude: destination.lat, longitude: destination.lon)
                let placemark = MKPlacemark(
                    coordinate: destCLoc.coordinate)
                view.addAnnotation(placemark)
            }
        }
    }
    


//MARK: - MapViewDelegate

class MapViewDelegate: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @StateObject var tripLogic = TripLogic.instance
    
    var parent: MapForTrip
    
    init(_ parent: MapForTrip) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let overlay = overlay as? RoutePolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = overlay.status == .active ? UIColor.blue.withAlphaComponent(0.75) : UIColor.blue.withAlphaComponent(0.25)
        renderer.lineWidth = 5
        //        renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
        return renderer
    }
    
    @objc func mapTapped(_ tap: TapGestureRecognizer) {
        
        if tap.state == .recognized {
            
            if let map = tap.map {
                
                let touchPT: CGPoint = tap.location(in: map)
                let coord: CLLocationCoordinate2D = map.convert(touchPT, toCoordinateFrom: map)
                let maxMeters: Double = meters(fromPixel: 22, at: touchPT, map: map)
                
                var nearestDistance: Float = MAXFLOAT
                var nearestPoly: RoutePolyline? = nil
                
                for overlay: MKOverlay in map.overlays {
                    
                    if let polyline = overlay as? RoutePolyline {
                        let distance: Float = Float(distanceOf(pt: MKMapPoint(coord), toPoly: polyline))
                        
                        if distance < nearestDistance {
                            nearestDistance = distance
                            nearestPoly = polyline
                        }
                    }
                }
                
                if Double(nearestDistance) <= maxMeters,
                   let nearestPoly = nearestPoly {
                    // PolyLine Touched
                    print("PolyLine Touched")
                    if nearestPoly.status == .inactive {
                        
                        for route in tripLogic.chosenRoutes {
                            if route.collectionID == nearestPoly.parentCollectionID {
                                route.polyline.status = .inactive
                            }
                        }
                        
                        nearestPoly.status = .active
                        
                    }
                }
            }
        }
    }
    
    func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        
        for n in 0..<poly.pointCount - 1 {
            
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points are not equal
                continue
            }
            
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            
            var ptClosest: MKMapPoint
            
            if u < 0.0 {
                ptClosest = ptA
            } else if u > 1.0 {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            
            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }
    
    func meters(fromPixel px: Int, at pt: CGPoint, map: MKMapView) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = map.convert(pt, toCoordinateFrom: map)
        let coordB: CLLocationCoordinate2D = map.convert(ptB, toCoordinateFrom: map)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
}

class RoutePolyline: MKPolyline {
    var status: RoutePolylineStatus?
    var parentCollectionID: String?
}

enum RoutePolylineStatus {
    case active, inactive
}

class TapGestureRecognizer: UITapGestureRecognizer {
    var map: MKMapView?
}
