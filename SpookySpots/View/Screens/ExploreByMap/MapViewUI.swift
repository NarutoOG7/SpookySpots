//
//  MapViewUI.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/10/22.
//

import SwiftUI
import MapKit

struct MapViewUI: UIViewRepresentable {
    
    
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    
    @ObservedObject var geoFireManager = GeoFireManager.instance
    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.setRegion(exploreByMapVM.region, animated: true)
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.addAnnotations(geoFireManager.gfOnMapLocations)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.addAnnotations(geoFireManager.gfOnMapLocations)
    }
    
    func makeCoordinator() -> MapCoordinator {
        .init()
    }
    
    func getRegion() -> MKCoordinateRegion {
        mapView.region
    }
    
    final class MapCoordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            switch annotation {
                
            case let cluster as MKClusterAnnotation:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = .black
                annotationView.titleVisibility = .hidden
                return annotationView
                
            case let locAnnotation as LocationAnnotationModel:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SpookySpot") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Spooky Spot")
                annotationView.canShowCallout = false
                annotationView.clusteringIdentifier = "cluster"
                annotationView.markerTintColor = .purple
                annotationView.titleVisibility = .visible

                return annotationView
                
            default: return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let annotation = view.annotation
            switch annotation {
                                
            case let locAnnotation as LocationAnnotationModel:
                
                ExploreByMapVM.instance.locAnnoTapped = locAnnotation
                print(locAnnotation)
                
            default: break
            }
        }
    }
}
