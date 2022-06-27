//
//  MapViewUI.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/10/22.
//

import SwiftUI
import MapKit

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
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.addAnnotations(geoFireManager.gfOnMapLocations)
        mapView.region = exploreVM.searchRegion
        addCurrentLocation(to: mapView)
    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            view.addAnnotation(
                MKPlacemark(coordinate: currentLocation.coordinate))
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
                
            case _ as MKClusterAnnotation:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = .black
                annotationView.titleVisibility = .hidden
                annotationView.subtitleVisibility = .hidden
                return annotationView
                
            case _ as LocationAnnotationModel:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SpookySpot") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Spooky Spot")
                annotationView.canShowCallout = false
                annotationView.clusteringIdentifier = "cluster"
                annotationView.markerTintColor = .purple
                annotationView.titleVisibility = .hidden
                annotationView.glyphText = "👻"

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
    }
}
