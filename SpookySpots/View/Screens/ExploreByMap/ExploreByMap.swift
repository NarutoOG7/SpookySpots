//
//  ExploreByMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation
import SwiftUITrackableScrollView

struct ExploreByMap: View {
    
    @State private var scrollViewContentOffset = CGFloat(0)
    
    @State private var visibleLocation: LocationModel?
    
    @ObservedObject var locationStore = LocationStore.instance
    
    @ObservedObject var exploreByListVM = ExploreByListVM.instance
    @ObservedObject var exploreByMapVM = ExploreByMapVM.instance
    
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
    }
}

//MARK: - Subviews

extension ExploreByMap {

    private var locationsList: AnyView {
        AnyView(
            TrackableScrollView(.horizontal, showIndicators: false, contentOffset: $scrollViewContentOffset) {
                HStack {
                    ForEach(locationStore.onMapLocations) { location in
                        //            LocationPreviewOnMap(location: location)
                        
                        NavigationLink {
                            LD(location: location)
                        } label: {
                            LargeImageLocationView(location: location)
                        }
                        .onAppear { self.visibleLocation = location }
                        
                        .onChange(of: visibleLocation) { newValue in
                            if let anno = GeoFireManager.instance.gfOnMapLocations.first(where: { $0.id == "\(location.location.id)" }) {
                                map.selectAnnotation(anno, animated: true)
                            }
                        }
                    }
                    
                }
            }
                .pagedScrollView()
        )
        
        
    }

    private var locationList: some View {
        let view: AnyView
        if exploreByMapVM.showingLocationList {
            view = locationsList
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
            
            List(exploreByMapVM.searchedLocations) { location in

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
        if exploreByMapVM.searchedLocations.isEmpty {
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
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: listButtonPressed)
    }
    
    private var currentLocationButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: currentLocationPressed)
    }
    
    //MARK: - Methods
    
    func listButtonPressed() {
        exploreByListVM.isShowingMap = false
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
