//
//  ExploreByMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation

struct ExploreByMap: View {
    
    @State private var swipeDirection: ExploreViewModel.SwipeDirection?
    
    @State private var shouldNavigate = false
    
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    let map = MapViewUI(mapIsForExplore: true)
    
    var body: some View {
        
        ZStack {
            map
                .ignoresSafeArea()
            searchView
            HStack {
                Spacer()
                
                VStack {
                    listButton
                    currentLocationButton
                    Spacer()
                }
                .padding(.top, 2)
                .padding(.horizontal)
            }
            
            locationList
                .padding()
            
        }
        
        .onAppear {
            GeoFireManager.instance.startLocationListener(region: map.getRegion())
        } .onDisappear {
            GeoFireManager.instance.endLocationListener()
        }
        
        .navigationTitle("Map")
        .navigationBarHidden(true)
        
        .fullScreenCover(isPresented: $shouldNavigate) {
            Binding($exploreVM.displayedLocation).map {
                LD(location: $0)
            }
        }
    }
    
    
    //MARK: - Subviews
    
    
    private var locationsList: some View {
        
        VStack {
            
            Spacer()
            
            ZStack {
                
                ForEach(locationStore.onMapLocations) { location in
                    
                    if exploreVM.displayedLocation == location {
                        
                        LargeImageLocationView(location: location)
                            .onTapGesture {
                                exploreVM.displayedLocation = location
                                self.shouldNavigate = true
                            }
                            .gesture(
                                DragGesture(minimumDistance: 3.0,
                                                   coordinateSpace: .local)
                                .onEnded({ value in
                                    
                                    switch (value.translation.width, value.translation.height) {
                                        
                                    case (...0, -200...200):
                                        print("left swipe")
                                        self.swipeDirection = .forward
                                        exploreVM.showLocationOnSwipe(direction: .forward)
                                        
                                        
                                    case (0..., -200...200):
                                        print("right swipe")
                                        self.swipeDirection = .backward
                                        exploreVM.showLocationOnSwipe(direction: .backward)
                                        
                                    case (-100...100, 0...):
                                        print("Up?")
                                        exploreVM.displayedLocation = nil
                                        exploreVM.highlightedAnnotation = nil
                                        
                                    default: print("no clue")
                                    }
                                }))
                            .transition(.asymmetric(
                                insertion: swipeDirection == .forward ? .move(edge: .trailing) : .move(edge: .leading),
                                removal: swipeDirection == .forward ? .move(edge: .leading) : .move(edge: .trailing)))
                    }
                }
            }
        }
    }
    
    private var searchView: some View {
        VStack {
            SearchBar()
                .padding(.horizontal)
                .padding(.trailing, 65)
            Spacer()
        }
    }
    
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
    
    //MARK: - Buttons
    
    private var listButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "list.bullet"),
                     mainColor: K.Colors.WeenyWitch.brown,
                     accentColor: K.Colors.WeenyWitch.lightest,
                     clicked: listButtonPressed)
    }
    
    private var currentLocationButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     mainColor: K.Colors.WeenyWitch.brown,
                     accentColor: K.Colors.WeenyWitch.lightest,
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
