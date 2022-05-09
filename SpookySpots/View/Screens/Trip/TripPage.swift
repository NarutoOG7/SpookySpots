//
//  TripPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//

import SwiftUI

struct TripPage: View {
    
    @ObservedObject var locationStore = LocationStore.instance
    @EnvironmentObject var tripLogic: TripLogic
    
    var body: some View {
        
        ZStack {
            
            MapForTrip()
                .ignoresSafeArea()
            
            SlideOverCard(position: .bottom, color: .white, handleColor: .black) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            durationView
                            distanceView
                        }
                        Spacer()
                        goOrGetRoutesButton
                    }
                    
                    startEnd
                    
                 destinationList
                }
                .padding(.horizontal)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(.white)
//                        .frame(width: UIScreen.main.bounds.width))
            }
        }
    }
    
    private var distanceView: some View {
        HStack(spacing: 16) {
            Text("233")
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("miles")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    private var durationView: some View {
        HStack(spacing: 7) {
            Text("4")
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("hr")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text("23")
                .font(.avenirNextRegular(size: 23))
                .fontWeight(.medium)
            Text("min")
                .font(.avenirNextRegular(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    private var startEnd: some View {
        VStack(alignment: .trailing) {
            
            HStack {
                Text("START:")
                    .font(.avenirNextRegular(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                startLink
            }
            
            HStack {
                Text("END:")
                    .font(.avenirNextRegular(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                endLink
            }
        }
    }
    
    private var destinationList: some View {
        List {
        ForEach(locationStore.activeTripLocations) { destination in
            Text(destination.name)
        }.onMove(perform: moveRow)
        }
    }
    
    //MARK: - Buttons/Links
    
    private var goOrGetRoutesButton: some View {
        Button(action: goOrGetTapped) {
            Text("Get Routes")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var startLink: some View {
        NavigationLink {
//            ChangeStartAndStop()
            LD(location: LocationModel.example)
        } label: {
            Text(tripLogic.currentTrip?.startLocation.name ?? "Not Here")
        }
    }
    
    private var endLink: some View {
        NavigationLink {
//            ChangeStartAndStop()
            LD(location: LocationModel.example)
        } label: {
            Text(tripLogic.currentTrip?.endLocation.name ?? "Not Here")
        }
    }
    
    //MARK: - Methods
    
    private func goOrGetTapped() {
        
    }
    
    private func moveRow(source: IndexSet, destination: Int) {
        locationStore.activeTripLocations.move(fromOffsets: source,toOffset: destination)
    }
}

struct TripPage_Previews: PreviewProvider {
    static var previews: some View {
        TripPage()
            .environmentObject(TripLogic())
    }
}
