//
//  RouteHelper.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/6/22.
//

import SwiftUI

struct RouteHelper: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                VStack {
                    VStack(alignment: .leading) {
                        
                        driveTime
                        distance
                        
                        
                        if tripLogic.alternates.indices.contains(0) {
                            ColorBar(position: 0, title: "1.", color: .green)
                        }
                        
                        if tripLogic.alternates.indices.contains(1) {
                            ColorBar(position: 1, title: "2.", color: .blue)
                        }
                        
                        if tripLogic.alternates.indices.contains(2) {
                            ColorBar(position: 2, title: "3.", color: .yellow)
                        }
                    }
                    moreRoutesButton
                    
                }
                .padding()
                .background(weenyWitch.lightest.cornerRadius(20))
            }
            .padding()
            .padding(.top, 100)
            Spacer()
            
        }
    }
    
    //MARK: - SubViews
    
    private var driveTime: some View {
        HStack {
            Image(systemName: "car.fill")
                .font(.caption)
                .foregroundColor(weenyWitch.brown)

            Text(tripLogic.getHighlightedRouteTravelTimeAsDigitalString() ?? "")
                .foregroundColor(weenyWitch.brown)
                .font(.avenirNext(size: 18))
        }
        .padding(.bottom, 2)
    }
    
    private var distance: some View {
        HStack {
            Image(systemName: "fuelpump.fill")
                .font(.caption)
                .foregroundColor(weenyWitch.brown)
            Text(tripLogic.getDistanceStringFromRoute(tripLogic.currentRoute ?? Route(), shortened: true))
                .foregroundColor(weenyWitch.brown)
                .font(.avenirNext(size: 18))
        }
    }
    
    //MARK: - Buttons
    
    private var moreRoutesButton: some View {
        Button(action: moreRoutesTapped) {
            if tripLogic.alternateRouteState == .selected && tripLogic.selectedAlternate != nil {
                Text("DONE")
                    .foregroundColor(weenyWitch.orange)
                    .font(.avenirNext(size: 18))
            } else if tripLogic.alternateRouteState == .showingAll {
                Text("cancel")
                    .foregroundColor(weenyWitch.orange)
                    .font(.avenirNext(size: 18))
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(weenyWitch.orange)
            }
        }
        .padding(.top)
    }
    
    //MARK: - Methods
    
    private func moreRoutesTapped() {
        tripLogic.alternatesLogic()
    }
}

struct RouteHelper_Previews: PreviewProvider {
    static var previews: some View {
        RouteHelper()
    }
}

