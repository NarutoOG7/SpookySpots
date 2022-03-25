//
//  TripScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import UniformTypeIdentifiers


struct TripScreen: View {
    
    @ObservedObject var tripPageVM = TripPageVM.instance
    
    @State var draggedItem: Location?
    
    @State var trip = TripPageVM.instance.trip
    
    var body: some View {
        
        
        ZStack {
            MapForTrip()
            
            SlideOverCard(color: Color.black) {
                ZStack {
                    VStack {
                        ZStack {
                            whiteBacking
                            HStack(spacing: 0.75) {
                                distance
                                duration
                            }.padding(.vertical, 3)
                            //                            .padding(.bottom, 40)
                        }
                        .frame(height: 120)
                        .offset(y: -10)
                        Spacer()
                        locationsList
                        Spacer()
                        
                    }
                }
            }
        }
        
    }
}

struct TripScreen_Previews: PreviewProvider {
    static var previews: some View {
        TripScreen()
    }
}

//MARK: - Subviews

extension TripScreen {
    
    // map with annotations on locations and on routes
    
    // distance , expected time
    // locations
    // start button
    
    
    private var whiteBacking: some View {
        VStack {
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width)
//                .offset(y: -10)
            
            Spacer()
        }
    }
    
    private var mainCover: some View {
        Rectangle()
            .frame(width: (UIScreen.main.bounds.width / 2))
//            .offset(y: -15)
    }
    
    private var distance: some View {
        ZStack {
            mainCover
            VStack(spacing: 3) {
                Text(trip?.milesAsString ?? "100 mi")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(Color.white)
                Text("DISTANCE")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                
            }
            .padding(.horizontal, 30)
        }
        .offset(y: -5.2)
    }
    
    private var duration: some View {
        ZStack {
            
            mainCover
            VStack(spacing: 3) {
                Text(trip?.durationAsString ?? "6 hrs")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(Color.white)
                Text("DURATION")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
            }
            .padding(.horizontal, 30)
        }
        .offset(y: -5.2)
    }
    
    private var locationsList: some View {
        VStack(alignment: .leading) {
            ForEach(tripPageVM.tripLocations) { location in
                HStack {
                    Text(location.name)
                        .font(.title2)
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 25, height: 16)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 4)
                
                .onDrag({
                    self.draggedItem = location
                    return NSItemProvider(item: nil, typeIdentifier: location.name)
                })
                .onDrop(of: [UTType.text], delegate: MyDropDelegate(location: location, locations: $tripPageVM.tripLocations, draggedItem: $draggedItem))
                
            }
        }
    }
    
    private var emptySpacer: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 50, height: 300)
    }
    
    //MARK: - Buttons
    
    
    //MARK: - Methods
}


//MARK: - MyDropDelegate
struct MyDropDelegate: DropDelegate {
    
    let location: Location
    @Binding var locations : [Location]
    @Binding var draggedItem: Location?
    @ObservedObject var tripPageVM = TripPageVM.instance
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        if draggedItem.id != location.id {
            if let from = locations.firstIndex(of: draggedItem),
               let to = locations.firstIndex(of: location) {
                withAnimation(.default) {
                    self.locations.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    tripPageVM.trip?.locations = locations
                }
            }
        }
    }
}

