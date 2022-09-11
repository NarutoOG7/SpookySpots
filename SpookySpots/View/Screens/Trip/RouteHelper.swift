//
//  RouteHelper.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/6/22.
//

import SwiftUI
import AVFoundation


struct RouteHelper: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                VStack {
                    
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
                    
                    moreRoutesButton
                    
                }
                .padding()
                .background(Color.white.cornerRadius(20))
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
            Text(tripLogic.getHighlightedRouteTravelTimeAsDigitalString() ?? "")
        }
        .padding(.bottom, 2)
    }
    
    private var distance: some View {
        HStack {
            Image(systemName: "fuelpump.fill")
                .font(.caption)
            Text(tripLogic.getSingleRouteDistanceAsString() )
        }
    }
    
    //MARK: - Buttons
    
    private var moreRoutesButton: some View {
        Button(action: moreRoutesTapped) {
            if tripLogic.alternateRouteState == .selected && tripLogic.selectedAlternate != nil {
                Text("DONE")
            } else if tripLogic.alternateRouteState == .showingAll {
                Text("cancel")
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
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


//MARK: - Color Bar

struct ColorBar: View {

    @EnvironmentObject var tripLogic: TripLogic

    var position: Int?
    var title: String?
    var color: Color
    
    var body: some View {
        HStack {
            Text(title ?? "")
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(width: 50, height: 12)
        }
        //        .padding(.vertical, 7)
        //        .padding(.horizontal, 12)
        .overlay(background.padding(-7))
        .onTapGesture(perform: onTapped)
    }

    //MARK: - Background
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 2)
            .fill(isSelected() ? .orange : .clear)
    }

    //MARK: - Methods

    private func isSelected() -> Bool {
        if let position = position {
            return tripLogic.positionIsSelected(position)
        }
        return false
    }

    private func onTapped() {
        if let position = position {
            tripLogic.selectAlternate(position)
        }
        tripLogic.alternateRouteState = .selected
    }
}


struct DirectionsLabel: View {

    let txt: String

    @Binding var isShowingMore: Bool

    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {

        Text(txt)
            .foregroundColor(.white)
            .frame(height: 75, alignment: .bottom)
            .frame(maxWidth: UIScreen.main.bounds.width - 60)
            .padding()
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: isShowingMore ? "arrow.up" : "arrow.down")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }


            .onAppear {
                let speechUtterance = AVSpeechUtterance(string: txt)
                    speechSynthesizer.speak(speechUtterance)
            }
    }
}

//MARK: - Total Trip Details String

struct DurationDistanceString: View {
    let time: Time
    let distanceAndUnit: (Double,String)
    var body: some View {
        Text("\(time.hours) hr \(time.minutes) min(\(Int(distanceAndUnit.0)) \(distanceAndUnit.1))")
    }
}

struct Time {
    var hours: Int = 0
    var minutes: Int = 0
}
