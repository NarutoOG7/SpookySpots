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

struct LazyView<Content: View>: View {

    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {

        self.build = build

    }

    var body: Content {

        build()

    }

}


struct MapView: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    var geoFireManager = GeoFireManager.instance


    var body: some View {
        LazyView(
        Map(coordinateRegion: $exploreByMapVM.region, showsUserLocation: true, annotationItems: geoFireManager.gfOnMapLocations) { location in

            MapAnnotation(coordinate: location.coordinate) {

//            MapAnnotation(coordinate: location.cLLocation?.coordinate ?? MapDetails.startingLocation.coordinate) {

                Button(action: {
                    exploreByMapVM.showingLocationList = true
//                    locationStore.selectedLocation = location
//                    print("location tapped \(location.name)")
                }, label: {
                    ZStack {
                        Circle()
                            .stroke(Color.yellow, lineWidth: 3)
//                        LocationImage(location: locationFromId(location.id))
//         LocAnnoImageView(location: location)
//                        LocationImage(location: location)
                    }
                    .frame(width: 70, height: 70)
                })
            }

        }
        .ignoresSafeArea()
        .accentColor(.pink)
        .onAppear {
            locationManager.checkIfLocationServicesIsEnabled()
//            geoFireManager.startLocationListener()
        } .onDisappear {
//            geoFireManager.endLocationListener()
        }
        .onTapGesture {
            exploreByMapVM.showingLocationList = false
        }
//            }
//        }
        )
    }
    
    func locationFromId(_ id: String) -> Location? {
        locationStore.onMapLocations.filter { "\($0.id)" == id }.first
    }
}

struct LocAnnoImageView: View {
    var location: Location?
    
    var body: some View {
        let imgView: Image
        if let location = location,
           let baseImage = location.baseImage {
            imgView = baseImage
        } else {
            imgView = Image("bannack")
        }
        return imgView
            .resizable()
            .aspectRatio(1, contentMode: .fit)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}



import SDWebImageSwiftUI
import Firebase

struct LocationImage: View {

    var location: Location?
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

//            let storage = Storage.storage().reference()
//            if let imageName = location.imageName {
//                storage.child(imageName).downloadURL { (url, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        guard let url = url else { return }
//                        DispatchQueue.main.async {
//                            self.url = "\(url)"
//                        }
//                    }
//                }
//            }
            loadImageFromFirebase()
        }
    }
    
    func loadImageFromFirebase() {
        if let location = location,
           let imageName = location.imageName {
            let storage = Storage.storage().reference(withPath: imageName)
            
            storage.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let url = url {
                    self.url = "\(url)"
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



import SDWebImageSwiftUI
import FirebaseStorage

struct FirebaseImage: View {
    
    var location: Location?
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        
        WebImage(url: imageURL)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear(perform: loadImageFromFirebase)
    }
    
    func loadImageFromFirebase() {
        if let location = location,
           let imageName = location.imageName {
            let storage = Storage.storage().reference(withPath: imageName)
            
            storage.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let url = url {
                    self.imageURL = url
                }
            }
        }
    }
}
