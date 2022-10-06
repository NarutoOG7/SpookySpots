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
        Text(tripLogic.currentTrip?.nextDestination?.name ?? "")
            .foregroundColor(weenyWitch.lightest)
    }
    
    private var durationAndDistance: some View {
        DurationDistanceString(
            time: tripLogic.currentRouteTravelTime ?? Time(),
            distanceString: tripLogic.currentRouteDistanceString ?? "")
        .foregroundColor(weenyWitch.lightest)
    }
}

struct NavigationHelper_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHelper()
    }
}
