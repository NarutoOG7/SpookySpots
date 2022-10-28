//
//  NavigationHelper.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/30/22.
//

import SwiftUI

struct NavigationHelper: View {
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack {
            destinationTitle
            durationAndDistance
        }
    }
    
    private var destinationTitle: some View {
        let trip = tripLogic.currentTrip
        let nextDestination = trip?.destinations[trip?.nextDestinationIndex ?? 0]
            
        return Text(nextDestination?.name ?? "")
                .foregroundColor(weenyWitch.lightest)
    }
    
    private var durationAndDistance: some View {
        DurationDistanceString(
            travelTime: tripLogic.currentRoute?.travelTime ?? 0,
            distanceInMeters: tripLogic.currentRoute?.distance ?? 0,
            isShortened: true,
            asStack: false)
        .foregroundColor(weenyWitch.lightest)
    }
}

struct NavigationHelper_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHelper()
    }
}
