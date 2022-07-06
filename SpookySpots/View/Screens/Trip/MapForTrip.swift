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
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        if tripLogic.isNavigating {
            mapView.setRegion(tripLogic.mapRegion, animated: true)
        }
        mapView.tintColor = .black
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        let mapTap = TapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped(_:)))
        mapTap.map = mapView
        mapView.addGestureRecognizer(mapTap)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if tripLogic.isNavigating {
            mapView.setRegion(tripLogic.mapRegion, animated: true)
        }
        addRoute(to: mapView)
        addPlacemarks(to: mapView)
        addCurrentLocation(to: mapView)
        addAlternateRoutes(to: mapView)
        addGeoFenceCirclesForTurnByTurnNavigation(to: mapView)
    }
    
    func makeCoordinator() -> MapViewDelegate {
        .init()
    }
    
    
    func addTapGestureRecognizer(to view: MKMapView) {
        
    }
    
    func addRoute(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        addActivePolylines(to: view)
    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            let startAnno = StartAnnotation(coordinate: currentLocation.coordinate, locationID: "START")
            let endAnno = EndAnnotation(coordinate: currentLocation.coordinate, locationID: "END")
            view.addAnnotations([startAnno, endAnno])
        }
    }
    
    func addPlacemarks(to view: MKMapView) {
        if let trip = tripLogic.currentTrip {
            for destination in trip.destinations {
                if let index = trip.destinations.firstIndex(where: { $0.id == destination.id }) {
                    let destCLoc = CLLocation(latitude: destination.lat, longitude: destination.lon)
                    let anno = LocationAnnotationModel(coordinate: destCLoc.coordinate, locationID: destination.id, title: "\(index + 1)")
                    view.addAnnotation(anno)
                }
            }
        }
    }
    
    func addActivePolylines(to view: MKMapView) {
        for route in tripLogic.tripRoutes {
            let polyline = route.polyline            
//            view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: ®10, left: 10, bottom: 10, right: 10), animated: true)
            view.addOverlay(polyline)
        }

    }
    
    func addAlternateRoutes(to view: MKMapView) {
        for route in tripLogic.alternates {
            let polyline = route.polyline
            view.addOverlay(polyline)
        }
    }
    
    func setCurrentLocationRegion() {
        if UserLocationManager.instance.locationServEnabled,
            let currentLoc = UserStore.instance.currentLocation {
//            mapView.setRegion(MKCoordinateRegion(center: currentLoc.coordinate, span: MapDetails.defaultSpan), animated: true)
            tripLogic.mapRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }
    
    func addGeoFenceCirclesForTurnByTurnNavigation(to view: MKMapView) {
        for circle in tripLogic.geoFencingCircles {
            view.addOverlay(circle)
        }
    }
    
    //MARK: - MapViewDelegate
    
    final class MapViewDelegate: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        
        @StateObject var tripLogic = TripLogic.instance
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if overlay is RoutePolyline {
                
                guard let overlay = overlay as? RoutePolyline else {
                    return MKOverlayRenderer(overlay: overlay)
                }
                
                
                let isHighlighted = tripLogic.routeIsHighlighted && tripLogic.highlightedPolyline == overlay
                let noneHighlighted = !tripLogic.routeIsHighlighted
                
                let isShowingAlternates = tripLogic.alternatesAreOnBoard()
                let isAlternate = tripLogic.alternates.contains(where: { $0.polyline == overlay })
                let isFirstAlt = tripLogic.alternates.first?.polyline == overlay
                let isSecondAlt = tripLogic.alternates.indices.contains(1) && tripLogic.alternates[1].polyline == overlay
                let isThirdAlt = tripLogic.alternates.indices.contains(2) && tripLogic.alternates[2].polyline == overlay
                
                var color: UIColor = .white
                var lineWidth: Int = 7
                
                if isShowingAlternates && !isAlternate {
                    // make gray
                    color = .gray.withAlphaComponent(0.33)
                } else if isAlternate {
                    
                    if isFirstAlt {
                        // make green
                        color = .systemGreen
                    } else if isSecondAlt {
                        // make blue
                        color = .systemBlue
                    } else if isThirdAlt {
                        // make yellow
                        color = .systemYellow
                    }
                    
                    //                if tripLogic.selecte
                    
                } else if !noneHighlighted && !isHighlighted {
                    // make transparent orange
                    color = .systemOrange.withAlphaComponent(0.33)
                } else if isHighlighted || noneHighlighted && !isShowingAlternates {
                    // make orange
                    color = .systemOrange
                }
                
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.lineWidth = 7
                renderer.strokeColor = UIColor.systemOrange
                renderer.strokeColor = color
                
                
                
                return renderer
                
            }
            
            if overlay is MKCircle {
                let renderer = MKCircleRenderer(overlay: overlay)
                renderer.strokeColor = .red
                renderer.fillColor = .red
                renderer.alpha = 0.5
                return renderer
            }
            
            return MKOverlayRenderer()
        }
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            switch annotation {
                
            case let anno as LocationAnnotationModel:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Destination") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Dest")
                
                annotationView.canShowCallout = false
                annotationView.markerTintColor = .purple
                annotationView.titleVisibility = .hidden
                annotationView.glyphText = anno.title
                
                return annotationView
                
                
            case _ as StartAnnotation:
                
                let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "START") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Start")
                annoView.canShowCallout = false
                annoView.markerTintColor = .white
                annoView.titleVisibility = .hidden
                annoView.glyphText = "🕺"
                
                return annoView
                
            case _ as EndAnnotation:
                
                let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "END") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "End")
                annoView.canShowCallout = false
                annoView.markerTintColor = .white
                annoView.titleVisibility = .hidden
                annoView.glyphText = "🕺"
                
                return annoView
                
            default: return nil
            }
        }
        
        @objc func mapTapped(_ tap: TapGestureRecognizer) {
            
            if tap.state == .recognized && !tripLogic.isNavigating {
                
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
                        tripLogic.highlightedPolyline = nearestPoly
                        tripLogic.routeIsHighlighted = true
                        
                        if tripLogic.alternatesAreOnBoard() {
                            tripLogic.selectedAlternate = nearestPoly.route
                        }
                       
//                        withAnimation(.easeInOut) {
//                        DispatchQueue.main.async {
//                            self.tripLogic.mapRegion = coordinateRegion
//                        }
//                            map.setCenter(center, animated: true)
//                            map.setRegion(coordinateRegion, animated: true)
//                        }
                    } else {
                        tripLogic.highlightedPolyline = nil
                        tripLogic.routeIsHighlighted = false
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

class TapGestureRecognizer: UITapGestureRecognizer {
    var map: MKMapView?
}

class RoutePolyline: MKPolyline, Identifiable {
    var id = UUID()
    var parentCollectionID: String?
    var color: Color?
    var route: Route?
    var startLocation: Destination?
    var endLocation: Destination?
}



extension Array where Element == CLLocationCoordinate2D {
    func center() -> CLLocationCoordinate2D {
        var maxLatitude: Double = -200;
        var maxLongitude: Double = -200;
        var minLatitude: Double = Double(MAXFLOAT);
        var minLongitude: Double = Double(MAXFLOAT);
        
        for location in self {
            if location.latitude < minLatitude {
                minLatitude = location.latitude;
            }
            
            if location.longitude < minLongitude {
                minLongitude = location.longitude;
            }
            
            if location.latitude > maxLatitude {
                maxLatitude = location.latitude;
            }
            
            if location.longitude > maxLongitude {
                maxLongitude = location.longitude;
            }
        }
        
        return CLLocationCoordinate2DMake(CLLocationDegrees((maxLatitude + minLatitude) * 0.5), CLLocationDegrees((maxLongitude + minLongitude) * 0.5));
    }
}
