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

    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    @ObservedObject var userStore = UserStore.instance
    
    @ObservedObject var geoFireManager = GeoFireManager.instance
    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.setRegion(exploreVM.searchRegion, animated: true)
//        setCurrentLocationRegion()
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.addAnnotations(geoFireManager.gfOnMapLocations)
        mapView.delegate = context.coordinator
        configureTileOverlay()
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.addAnnotations(geoFireManager.gfOnMapLocations)
        mapView.region = exploreVM.searchRegion
        addCurrentLocation(to: mapView)
    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            let plc = StartAnnotation(coordinate: currentLocation.coordinate, locationID: "0")
            view.addAnnotation(plc)
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        .init()
    }
    
    func getRegion() -> MKCoordinateRegion {
        mapView.region
    }
    
    func setCurrentLocationRegion() {
        if UserLocationManager.instance.locationServEnabled,
            let currentLoc = UserStore.instance.currentLocation {
            mapView.setRegion(MKCoordinateRegion(center: currentLoc.coordinate, span: MapDetails.defaultSpan), animated: false)
            exploreVM.searchRegion = mapView.region
        }
    }
    
    func selectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.selectAnnotation(anno, animated: animated)
    }
    
    func deselectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.deselectAnnotation(anno, animated: animated)
    }
    
    //MARK: - Coordinator
    
    final class MapCoordinator: NSObject, MKMapViewDelegate {
        
        @ObservedObject var exploreVM = ExploreViewModel.instance
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            switch annotation {
                
            case _ as StartAnnotation:
                let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "START") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Start")
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
                
            case _ as LocationAnnotationModel:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SpookySpot") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Spooky Spot")
                annotationView.canShowCallout = false
                annotationView.clusteringIdentifier = "cluster"
                annotationView.markerTintColor = UIColor(K.Colors.WeenyWitch.black)
                annotationView.titleVisibility = .hidden
                annotationView.glyphText = "👻"
//                annotationView.glyphImage = UIImage(named: "Ghost")

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
                
                if let loc = LocationStore.instance.onMapLocations.first(where: { "\($0.location.id)"
                    == locAnnotation.id }) {
                    exploreVM.displayedLocation = loc
                }
            default: break
            }
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            for anno in mapView.annotations {
                switch anno {
                    
                case let locAnno as LocationAnnotationModel:
                    
                    if locAnno == exploreVM.highlightedAnnotation {
                        mapView.selectAnnotation(locAnno, animated: true)
                    }
                    
                default: break
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let tileOverlay as MKTileOverlay:
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            default:
                return MKOverlayRenderer(overlay: overlay)
            }
        }
        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//                // This is the final step. This code can be copied and pasted into your project
//                // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
//                // for displaying the tile overlay.
//                if let tileOverlay = overlay as? MKTileOverlay {
//                    return MKTileOverlayRenderer(tileOverlay: tileOverlay)
//                } else {
//                    return MKOverlayRenderer(overlay: overlay)
//                }
//        }
    }
//MARK: - MapKit Style
    
    private func configureTileOverlay() {
            // We first need to have the path of the overlay configuration JSON
            guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else {
                    return
            }
            let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
            
            // After that, you can create the tile overlay using MapKitGoogleStyler
            guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
                return
            }
            
            // And finally add it to your MKMapView
            mapView.addOverlay(tileOverlay)
    }

}

