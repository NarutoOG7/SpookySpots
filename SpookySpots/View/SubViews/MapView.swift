//
//  MapView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit
import CoreLocation
import GeoFire

struct MapView: View {
    
    @State var locationStore = LocationStore.instance
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    
    var body: some View {
//        ForEach(locationStore.locations) { location in
//            if locationIsInRegion(location: location, region: locationManager.region) {
//
//
        Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationStore.onMapLocations) { location in
            
            
            
            MapAnnotation(coordinate: location.cLLocation?.coordinate ?? CLLocationCoordinate2D()) {
                
                Button(action: {
                    locationStore.selectedLocation = location
                    print("location tapped \(location.name)")
                }, label: {
                    ZStack {
                        Circle()
                            .stroke(
                                exploreByMapVM.locationShownOnList == location ?
                                    Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)) : Color.yellow,
                                lineWidth: 3)
                        
                        
                        
                        LocationImage(location: location)
                        
                    }
                    .frame(width: 70, height: 70)
                })
            }
            
        }
        .ignoresSafeArea()
        .accentColor(.pink)
        .onAppear {
            locationManager.checkIfLocationServicesIsEnabled()
        }
//            }
//        }
    }
    
    private func locationIsInRegion(location: Location, region: MKCoordinateRegion) -> Bool {
        if let cLLocation = location.cLLocation {
            
            let circularRegion = CLCircularRegion(center: region.center, radius: region.span.longitudeDelta, identifier: "MapRegion")
            return circularRegion.contains(cLLocation.coordinate)
        }
        return false
    }
    
    private func locationIsInRegionSecond(location: Location, region: MKCoordinateRegion) -> Bool {
        if let cLLocation = location.cLLocation {
            let coordinates = cLLocation.coordinate
            let origin = MKMapPoint(coordinates)
            let size = MKMapSize(width: region.span.longitudeDelta, height: region.span.latitudeDelta)
            let mapRect = MKMapRect(origin: origin, size: size)
            let point = MKMapPoint(coordinates)
            if mapRect.contains(point) {
                return true
            }
        }
        return false
    }
}


import SDWebImageSwiftUI
import Firebase

struct LocationImage: View {
    
    var location: Location
    @State var url = ""
    
    var body: some View {
        
        VStack {
            
            if url == "" {
                Loader()
            } else {
                WebImage(url: URL(string: url)!)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(35)
                    .frame(width: 69.7, height: 69.7)
            }
        }
        .onAppear {
            
            let storage = Storage.storage().reference()
            if let imageName = location.imageName {
                storage.child(imageName).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        guard let url = url else { return }
                        DispatchQueue.main.async {
                            self.url = "\(url)"
                        }
                    }
                }
            }
        }
    }
}

struct Loader : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Loader>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Loader>) {
        
    }
}


