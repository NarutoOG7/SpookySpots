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
    
    @State var onMapLocs: [Location] = []
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    var geoFireManager = GeoFireManager.instance
//    @State var region = MKCoordinateRegion(center: MapDetails.startingLocation.coordinate,
//                                               span: MapDetails.defaultSpan)
    

    var body: some View {
//        ForEach(locationStore.locations) { location in
//            if locationIsInRegion(location: location, region: locationManager.region) {
//
//
        Map(coordinateRegion: $exploreByMapVM.region, showsUserLocation: true, annotationItems: onMapLocs) { location in
                        
            MapAnnotation(coordinate: location.cLLocation?.coordinate ?? MapDetails.startingLocation.coordinate) {
                
                Button(action: {
//                    locationStore.selectedLocation = location
//                    print("location tapped \(location.name)")
                }, label: {
                    ZStack {
                        Circle()
                            .stroke(Color.yellow, lineWidth: 3)
                        
                        
                        
//                        LocationImage(locationID: location.id)
                    }
                    .frame(width: 70, height: 70)
                })
            }
            
        }
        .ignoresSafeArea()
        .accentColor(.pink)
        .onAppear {
            locationManager.checkIfLocationServicesIsEnabled()
            geoFireManager.startLocationListener()
//            geoFireManager.removeGeoFireLocations()
        } .onDisappear {
            geoFireManager.endLocationListener()
        }
//            }
//        }
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


