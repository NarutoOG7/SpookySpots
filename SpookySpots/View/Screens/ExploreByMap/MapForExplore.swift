//
//  MapForExplore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/25/22.
//

import SwiftUI
import MapKit


struct MapForExplore: UIViewRepresentable {
    
    let exploreMapDelegate = ExploreMapDelegate()
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    @ObservedObject var userStore = UserStore.instance
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let region = exploreByMapVM.region
        mapView.setRegion(region, animated: true)
//        addAnnotations(to: mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = exploreMapDelegate
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
//        addAnnotations(to: uiView)

    }
    
    func addCurrentLocation(to view: MKMapView) {
        if let currentLocation = userStore.currentLocation {
            view.addAnnotation(
                MKPlacemark(coordinate: currentLocation.coordinate))
        }
    }
    
//    func addAnnotations(to view: MKMapView) {
//        let locations = locationStore.onMapLocations
//        for location in locations {
//            let coordinate = location.coordinate
//            let placemark = MKPlacemark(coordinate: coordinate)
//            view.addAnnotation(placemark)
//        }
//    }
    
}


//MARK: - ExploreMapDelegate

class ExploreMapDelegate: NSObject, MKMapViewDelegate {
    
    @ObservedObject var locationStore = LocationStore.instance
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let annoIdentifier = "SpookySpots"
//        var annotationView: MKAnnotationView?
//
//        if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
//            annotationView = deqAnno
//            annotationView?.annotation = annotation
//        } else {
//            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView = av
//        }
//
//        if let annotationView = annotationView,
//        let anno = annotation as? LocationAnnotationModel {
//            let image = UIImage(named: "bannack")
//            annotationView.image = image
//        }
//
//        return annotationView
//    }
//
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(
            latitude: mapView.centerCoordinate.latitude,
            longitude: mapView.centerCoordinate.longitude)
        
        print(locationStore.onMapLocations.count)
        
//        FirebaseManager.instance.showSpotsOnMap(location: loc) { locAnnoModel in
//            if !self.locationStore.onMapLocations.contains(locAnnoModel) {
//            self.locationStore.onMapLocations.append(locAnnoModel)
//            }
//        }
        
        
    }
    
    
}
