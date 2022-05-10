//
//  NavigationScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import SwiftUI
import MapKit

struct NavigationScreen: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    private var firstStep: some View {
        HStack {
            Image("")
            Text(tripLogic.)
        }
    }
}

struct NavigationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationScreen()
            .environmentObject(TripLogic())
    }
}

/*
 
 start on
 turn left
 turn right
 continue straight
 slight left
 slight right
 merge left
 merge right
 take exit right
 take exit left
 u turn
 
 */
