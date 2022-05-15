//
//  NavigationScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/10/22.
//

import SwiftUI
import MapKit

struct NavigationScreen: View {
        
    @State var isShowingMoreSteps = false
    
    @EnvironmentObject var tripLogic: TripLogic
    
    @ObservedObject var userStore = UserStore.instance
    
    var body: some View {
        ZStack {
            
            // Map For Navigation
            
            VStack{
                nextStep
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        durationView
                        distanceView
                    }
                    .frame(maxWidth: .infinity)
                    endButton
                        .frame(maxWidth: .infinity)
                        .offset(x: 30)
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width, height:  200)
                .background(.thickMaterial)
                .cornerRadius(10)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            currentLocationButton
            
            VStack{
                VStack {
                currentStep
                    if isShowingMoreSteps {
                    allRemainingSteps
                    }
                }
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                Spacer()
            }
        }
    }
    
    private var currentStep: some View {

        Button {
            self.isShowingMoreSteps.toggle()
            
        } label: {
            
            HStack {
                Image("")
                Text("Start on Richmond Dr")
                    .frame(height: 50)
                    .frame(maxWidth: UIScreen.main.bounds.width - 60)
            .padding()
            .overlay(alignment: .trailing) {
                Image(systemName: isShowingMoreSteps ? "arrow.up" : "arrow.down")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
            }
            }
        }
    }
    
    private var nextStep: some View {
        HStack {
            Image("")
            Text("Turn Left")
        }
    }
    
    private var allRemainingSteps: some View {
        List(tripLogic.navigation.steps, id: \.self) { step in
            Text(step.instructions)
        }
    }
    
    private var distanceView: some View {
        HStack(spacing: 16) {
            Text(tripLogic.distanceAsString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("miles")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    private var durationView: some View {
        HStack(spacing: 10) {
            Text(tripLogic.durationHoursString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("hr")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(tripLogic.durationMinutesString)
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("min")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    //MARK: - Buttons
    
    private var moreStepsButton: some View {
        Button(action: moreStepsTapped) {
            
        }
    }
    
    private var currentLocationButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
            
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     outlineColor: .black,
                     iconColor: .black,
                     backgroundColor: .white,
                     clicked: currentLocationPressed)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var endButton: some View {
        Button(action: endTapped) {
            Text("END")
                .font(.title)
                .padding(7)
        }
        .buttonStyle(.borderedProminent)
    }
    
    //MARK: - Methods
    
    private func currentLocationPressed() {
        // map . set currentLocation Region
    }
    
    private func endTapped() {
        // trip logic .end navigation
    }
    
    private func moreStepsTapped() {
        
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
