//
//  TheTripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/3/22.
//

import SwiftUI

struct TheTripPage: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    destinationTitle
                    tripLegDetails
                }
                huntButton
            }
            destinationsList
            totalTripDetails
        }
    }
    
    var destinationTitle: some View {
        Text(tripLogic.currentDestination?.name ?? "")
            .foregroundColor(weenyWitch.black)
    }
    
    private var tripLegDetails: some View {
        DurationDistanceString(
            time: tripLogic.getHighlightedRouteTravelTimeAsTime() ?? Time(),
            distanceAndUnit: tripLogic.getCurrentRouteDistanceAndUnit())
    }
    
    private var totalTripDetails: some View {
        DurationDistanceString(time: tripLogic.totalTripDurationAsTime, distanceAndUnit: tripLogic.getTotalDistanceAndUnit())
    }
    
    private var destinationsList: some View {
        let currentTrip = tripLogic.currentTrip
        let startLocation = currentTrip?.startLocation
        let endLocation = currentTrip?.endLocation
        return List {
            TripDestinationCell(
                mainText: startLocation?.name ?? "",
                subText: startLocation?.address ?? "",
                isCurrent: tripLogic.currentTrip?.recentlyCompletedDestination == startLocation,
                isCompleted: tripLogic.currentTrip?.completedDestinations.contains(startLocation ?? Destination()) ?? false,
                isLast: false)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))

            
            ForEach(tripLogic.currentTrip?.destinations ?? []) { destination in
                TripDestinationCell(
                    mainText: destination.name,
                    subText: destination.address,
                    isCurrent: tripLogic.currentTrip?.recentlyCompletedDestination == destination,
                    isCompleted: tripLogic.currentTrip?.completedDestinations.contains(destination) ?? false,
                    isLast: endLocation == destination)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
            
            TripDestinationCell(
                mainText: endLocation?.name ?? "",
                subText: endLocation?.address ?? "",
                isCurrent: false,
                isCompleted: tripLogic.currentTrip?.completedDestinations.contains(endLocation ?? Destination()) ?? false,
                isLast: true)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
        }
        .padding()
        .listStyle(.plain)
    }
    
    //MARK: - Buttons
    
    private var huntButton: some View {
        Button(action: huntTapped) {
            Text("HUNT")
                .foregroundColor(weenyWitch.orange)
        }
    }
    
    //MARK: - Methods
    
    private func huntTapped() {
        // Start Navigation
    }
}

struct TheTripPage_Previews: PreviewProvider {
    static var previews: some View {
        TheTripPage()
    }
}

struct TripDestinationCell: View {
    
    let mainText: String
    let subText: String
    let isCurrent: Bool
    let isCompleted: Bool
    let isLast: Bool
    
    private let images = K.Images.Trip.self
    private let colors = K.Colors.WeenyWitch.self
    
    var body: some View {
        HStack {
            self.image()
                .resizable()
            .frame(width: 60, height: 60)
            .edgesIgnoringSafeArea(.vertical)
            
            
            VStack(alignment: .leading) {
                
                Text(mainText)
                    .foregroundColor(colors.black)
                    .font(.avenirNext(size: 20))
                
                Text(subText)
                    .foregroundColor(colors.light)
                    .font(.avenirNext(size: 17))
            }
            .frame(height: 60)
            
        }
    }
    
    private func image() -> Image {
        // if is completed
        isCompleted ? images.completed :
        // if is current
        (isCurrent ? images.currentLocationIconWithDots :
        // if is last
        (isLast ? images.lastDestinationIcon :
        // otherwise
        images.destinationIcon))
    }
}
