//
//  ExploreByMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation

struct ExploreByMap: View {
    
    @State private var scrollViewContentOffset = CGFloat(0)
    
    @State private var visibleLocation: LocationModel?
    
    @State private var swipeDirection: ExploreViewModel.SwipeDirection?
    
    @State private var shouldNavigate = false
    
    @State private var navigateToLocation: LocationModel?
    
    @ObservedObject var locationStore = LocationStore.instance
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    let map = MapViewUI()
    
    var body: some View {
        
        ZStack {
            map
                .ignoresSafeArea()
            VStack {
                HStack {
                     SearchBar(type: .exploreByMap)
                        .offset(y: -30)
                    VStack {
                        listButton
                        currentLocationButton
                    }
                }.padding()
                Spacer()
            }
            locationList

        }
        
        .onAppear {
            GeoFireManager.instance.startLocationListener(region: map.getRegion())
        } .onDisappear {
            GeoFireManager.instance.endLocationListener()
        }
        
        .navigationTitle("Map")
        .navigationBarHidden(true)
        
        .fullScreenCover(isPresented: $shouldNavigate) {
            LD(location: navigateToLocation ?? LocationModel.example)
        }
    }
}

//MARK: - Subviews

extension ExploreByMap {
    
    private var locationsList: some View {
        VStack {
            Spacer()
        ZStack {
            ForEach(locationStore.onMapLocations) { location in
                if exploreVM.displayedLocation == location {
                    LargeImageLocationView(location: location)
                        
                        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                            .onEnded({ value in
                                switch (value.translation.width, value.translation.height) {
                                case (...0, -200...200):
                                    print("left swipe")
                                    self.swipeDirection = .forward
                                    if let anno = exploreVM.highlightedAnnotation {
                                    map.deselectAnnotation(anno, animated: true)
                                    exploreVM.showLocationOnSwipe(direction: .forward)
                                        print(anno.id)
                                        DispatchQueue.main.async {
                                            map.selectAnnotation(anno, animated: true)
                                        }
                                    }
                                case (0..., -200...200):
                                    print("right swipe")
                                    self.swipeDirection = .backward
                                    exploreVM.showLocationOnSwipe(direction: .backward)
                                default: print("no clue")
                                    print(value.translation.height)
                                }
                            }))
                        .transition(.asymmetric(
                            insertion: swipeDirection == .forward ? .move(edge: .trailing) : .move(edge: .leading),
                            removal: swipeDirection == .forward ? .move(edge: .leading) : .move(edge: .trailing)))
                    
                        .onTapGesture {
                            self.navigateToLocation = location
                            self.shouldNavigate = true
                        }
                }
            }
        }
        }
    }

//    private var locationsList: AnyView {
//        AnyView(
//            ScrollView {
//                HStack {
//                    ForEach(locationStore.onMapLocations) { location in
//                        //            LocationPreviewOnMap(location: location)
//
//                        NavigationLink {
//                            LD(location: location)
//                        } label: {
//                            LargeImageLocationView(location: location)
//                        }
//                        .onAppear { self.visibleLocation = location }
//
//                        .onChange(of: visibleLocation) { newValue in
//                            if let anno = GeoFireManager.instance.gfOnMapLocations.first(where: { $0.id == "\(location.location.id)" }) {
//                                map.selectAnnotation(anno, animated: true)
//                            }
//                        }
//                    }
//
//                }
//            }
//                .pagedScrollView()
//        )
//
//
//    }

    private var locationList: some View {
        let view: AnyView
        if exploreVM.showingLocationList {
            view = AnyView(locationsList)
        } else {
            view = AnyView(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 200))
        }
        return view
    }
    
    private var searchLocations: some View {
        VStack {
            
            List(exploreVM.searchedLocations) { location in

                NavigationLink {
                    LD(location: location)
                } label: {
                    Text("\(location.location.name), \(location.location.address?.state ?? "")")
                }
                
            }
            .listStyle(.plain)
            .frame(width: 276, height: 300)
            Spacer()
        }.frame(maxHeight: 222)
            .shadow(color: .black, radius: 2, x: 0, y: 0)
        
    }
    
    private var searchResults: some View {
        let view: AnyView
        if exploreVM.searchedLocations.isEmpty {
            view = AnyView(EmptyView())
        } else {
            view = AnyView(searchLocations)
        }
        return view
            .offset(y: 26)
    }
    
    
    //MARK: - Buttons
    
    private var listButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "list.bullet"),
                     outlineColor: K.Colors.WeenyWitch.brown,
                     iconColor: K.Colors.WeenyWitch.orange,
                     backgroundColor: K.Colors.WeenyWitch.lightest,
                     clicked: listButtonPressed)
    }
    
    private var currentLocationButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     outlineColor: K.Colors.WeenyWitch.brown,
                     iconColor: K.Colors.WeenyWitch.orange,
                     backgroundColor: K.Colors.WeenyWitch.lightest,
                     clicked: currentLocationPressed)
    }
    
    //MARK: - Methods
    
    func listButtonPressed() {
        exploreVM.isShowingMap = false
    }
    
    func currentLocationPressed() {
        map.setCurrentLocationRegion()
    }
    
}



//MARK: - Preview
struct ExploreByMap_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByMap()
            .previewInterfaceOrientation(.portrait)
    }
}
