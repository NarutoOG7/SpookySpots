//
//  MapViewUI.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/10/22.
//

import SwiftUI
import MapKit
import MapKitGoogleStyler


struct MapViewUI: UIViewRepresentable {
        
    @State var shouldCenterOnCurrentLocation = true
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var tripLogic = TripLogic.instance
    @ObservedObject var geoFireManager = GeoFireManager.instance
     
    var mapView = MKMapView()
    
    var mapIsForExplore: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.setRegion(exploreVM.searchRegion, animated: true)
        mapView.mapType = .satellite
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.delegate = context.coordinator
        
        addCorrectOverlays(to: mapView)
            
        let mapTap = TapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped(_:)))
        mapTap.map = mapView
        mapView.addGestureRecognizer(mapTap)
        
        self.configureTileOverlay()
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {

        updateRegion(mapView)
        
        addCorrectOverlays(to: mapView)
        
    }
    
    func updateRegion(_ mapView: MKMapView) {
        
        if shouldCenterOnCurrentLocation {
            
            mapView.setRegion(exploreVM.searchRegion, animated: true)
            
        }
    }
    
    func addCorrectOverlays(to mapView: MKMapView) {
        
        if mapIsForExplore {
            
            mapView.addAnnotations(geoFireManager.gfOnMapLocations)
            mapView.region = exploreVM.searchRegion
            addCurrentLocation(to: mapView)
            
        } else {
            
            addRoute(to: mapView)
            addPlacemarks(to: mapView)
            addStartAndEndLocations(to: mapView)
            addAlternateRoutes(to: mapView)
            addGeoFenceCirclesForTurnByTurnNavigation(to: mapView)
            
        }
    }
    
    func addCurrentLocation(to view: MKMapView) {
        
        if let currentLocation = userStore.currentLocation {
            
            let plc = StartAnnotation(coordinate: currentLocation.coordinate, locationID: "0")
            
            view.addAnnotation(plc)
        }
    }
    
    func addRoute(to view: MKMapView) {
            addRoutePolylineFromTrip(to: view)
    }
    
    func addStartAndEndLocations(to view: MKMapView) {
        
        if let start = tripLogic.currentTrip?.startLocation,
           let end = tripLogic.currentTrip?.endLocation {
            
            let startAnno = StartAnnotation(coordinate: CLLocationCoordinate2D(latitude: start.lat, longitude: start.lon), locationID: start.id)
            
            let endAnno = EndAnnotation(coordinate: CLLocationCoordinate2D(latitude: end.lat, longitude: end.lon), locationID: end.id)
            
            view.addAnnotations([startAnno, endAnno])
        }
    }
    
    func addPlacemarks(to view: MKMapView) {
        
        view.removeAnnotations(view.annotations)
        
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
    
    func addAlternateRoutes(to view: MKMapView) {
        
        for overlay in view.overlays {
            
            if overlay is RoutePolyline {
                
                for route in tripLogic.currentTrip?.routes ?? [] {
                    
                    if route.collectionID == tripLogic.alternates.first?.collectionID {
                        
                        view.removeOverlay(overlay)
                    }
                }
            }
        }
        for route in tripLogic.alternates {
            
            if let polyline = route.polyline {
                
                view.addOverlay(polyline)
            }
        }
    }
    
    func addRoutePolylineFromTrip(to view: MKMapView) {
        
        for overlay in view.overlays {
            
            if overlay is RoutePolyline {
                
                view.removeOverlay(overlay)
            }
            
        }
        
        if let routes = tripLogic.currentTrip?.routes {
            
            for route in routes {
                
                if let polyline = route.polyline {
                    
                    view.addOverlay(polyline)
                }
            }
        }
    }

    
    func makeCoordinator() -> MapCoordinator {
        .init(mapIsForExplore: mapIsForExplore, parent: self)
    }
    
    func getRegion() -> MKCoordinateRegion {
        mapView.region
    }
    
    func setCurrentLocationRegion() {
        
        let locationServicesEnabled = UserLocationManager.instance.locationServicesEnabled
        
        if locationServicesEnabled,
           let startLoc = tripLogic.currentTrip?.startLocation {
            
            DispatchQueue.main.async {
                
                let coordinates = CLLocationCoordinate2D(latitude: startLoc.lat, longitude: startLoc.lon)
                
                let span =  MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                
                self.exploreVM.searchRegion = MKCoordinateRegion(center: coordinates, span: span)
            }
        }
    }
    
    func selectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.selectAnnotation(anno, animated: animated)
    }
    
    func deselectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.deselectAnnotation(anno, animated: animated)
    }
    
    func addGeoFenceCirclesForTurnByTurnNavigation(to view: MKMapView) {
        
        for circle in tripLogic.geoFencingCircles {
            
            view.addOverlay(circle)
        }
    }
    
    //MARK: - Coordinator
    
    final class MapCoordinator: NSObject, MKMapViewDelegate {
        
        var mapIsForExplore: Bool
        var parent: MapViewUI
        
        @ObservedObject var exploreVM = ExploreViewModel.instance
        @ObservedObject var tripLogic = TripLogic.instance
                
        init(mapIsForExplore: Bool,
             parent: MapViewUI) {
            
            self.mapIsForExplore = mapIsForExplore
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            switch annotation {
                
                case let anno as LocationAnnotationModel:
                    
                if mapIsForExplore {

                    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SpookySpot") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Spooky Spot")
                    annotationView.canShowCallout = true
                    annotationView.clusteringIdentifier = "cluster"
                    annotationView.markerTintColor = UIColor(K.Colors.WeenyWitch.black)
                    annotationView.largeContentTitle = "Spooky Spot"
                    annotationView.titleVisibility = exploreVM.searchRegion.span.latitudeDelta <= 0.02 ? .visible : .hidden

                    annotationView.glyphImage = UIImage(named: "Ghost")
                    
                    return annotationView
                    
                } else {
                    
                    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Destination") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Dest")
                    
                    annotationView.canShowCallout = false
                    annotationView.markerTintColor = .purple
                    annotationView.titleVisibility = .hidden
                    annotationView.glyphText = anno.title
                    
                    return annotationView
                }
   
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
    
            case _ as MKClusterAnnotation:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = UIColor(K.Colors.WeenyWitch.lightest)
                annotationView.titleVisibility = .hidden
                annotationView.subtitleVisibility = .hidden
                return annotationView
                
            default: return nil
                
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            let annotation = view.annotation
            
            switch annotation {
                
            case let locAnnotation as LocationAnnotationModel:
                
                exploreVM.showingLocationList = true
                
                exploreVM.highlightedAnnotation = locAnnotation
                
                if let loc = LocationStore.instance.onMapLocations.first(where: { "\($0.location.id)" == locAnnotation.id }) {
                    
                    exploreVM.displayedLocation = loc
                }
                
            case let cluster as MKClusterAnnotation:
                
                let coordinate = cluster.coordinate
                
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                
                let newRegion = MKCoordinateRegion(center: coordinate, span: span)
                
                exploreVM.searchRegion = newRegion
                
            default: return
                
            }
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            
            for anno in mapView.annotations {
                
                switch anno {
                    
                case let locAnno as LocationAnnotationModel:
                    
                    if locAnno == exploreVM.highlightedAnnotation {
                        
                        mapView.selectAnnotation(locAnno, animated: true)
                    }
                    
                default: return
                    
                }
            }
        }
                        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            switch overlay {
                
            case let tileOverlay as MKTileOverlay:
                
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
                
            case is MKCircle:
                
                    let renderer = MKCircleRenderer(overlay: overlay)
                    renderer.strokeColor = .clear
                    renderer.fillColor = .clear
                
                    return renderer
                
            case _ as RoutePolyline:
                
                guard let overlay = overlay as? RoutePolyline else {
                    
                    return MKOverlayRenderer(overlay: overlay)
                }
                
                
                let isHighlighted = tripLogic.routeIsHighlighted && tripLogic.currentRoute?.polyline == overlay
                let noneHighlighted = !tripLogic.routeIsHighlighted
                
                let isShowingAlternates = tripLogic.alternatesAreOnBoard()
                let isAlternate = tripLogic.alternates.contains(where: { $0.polyline == overlay })
                
                let isFirstAlt = tripLogic.alternates.first?.polyline == overlay
                let isSecondAlt = tripLogic.alternates.indices.contains(1) && tripLogic.alternates[1].polyline == overlay
                let isThirdAlt = tripLogic.alternates.indices.contains(2) && tripLogic.alternates[2].polyline == overlay
                
                var color: UIColor = .white
                
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

                } else if !noneHighlighted && !isHighlighted {
                    // make accent
                    color = UIColor(K.Colors.WeenyWitch.lightest).withAlphaComponent(0.66)
                    
                } else if isHighlighted || noneHighlighted && !isShowingAlternates {
                    // make main
                    color = UIColor(K.Colors.WeenyWitch.lightest)
                }
                
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.lineWidth = 7
                renderer.strokeColor = UIColor.systemOrange
                renderer.strokeColor = color
                
                return renderer
                
            case let routePolyline as MKPolyline :
                
                    let renderer = MKPolylineRenderer(polyline: routePolyline)
                    renderer.lineWidth = 7
                    renderer.strokeColor = UIColor.blue
                
                    return renderer
                
            default:
                
                return MKOverlayRenderer(overlay: overlay)
            }
        }
        
        @objc func mapTapped(_ tap: TapGestureRecognizer) {
            
            if (tap.state == .recognized) && !(tripLogic.currentTrip?.tripState == .navigating) {
                
                if let map = tap.map {
                    
                    if !mapIsForExplore {
                        
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
                            handlePolylineTap(nearestPoly)
                            
                        } else {
                            // No Polyline
                            self.parent.shouldCenterOnCurrentLocation = true
                            tripLogic.currentRoute = nil
                            tripLogic.routeIsHighlighted = false
                        }
                    }
                }
            }
            
            func handlePolylineTap(_ nearestPoly: RoutePolyline) {

                if tripLogic.alternatesAreOnBoard() {
                    
                    tripLogic.selectedAlternate = tripLogic.alternates.first(where: { $0.id == nearestPoly.routeID })
                    
                    tripLogic.currentRoute = tripLogic.selectedAlternate
                    
                } else {
                    
                    tripLogic.currentRoute = tripLogic.currentTrip?.routes.first(where: { $0.id == nearestPoly.routeID })
                }
                
                tripLogic.routeIsHighlighted = true
                
                self.parent.shouldCenterOnCurrentLocation = false
            }
            
        }
        
        func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
            
            var distance: Double = Double(MAXFLOAT)
            
            if poly.pointCount > 0 {
                
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
    

    //MARK: - MapKit Style
    
    func configureTileOverlay() {
  
            guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else { return }
        
            let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
            
            guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else { return }
        
            tileOverlay.canReplaceMapContent = true
        
            mapView.addOverlay(tileOverlay)
        
    }
    
    

}

class TapGestureRecognizer: UITapGestureRecognizer {
    var map: MKMapView?
}
