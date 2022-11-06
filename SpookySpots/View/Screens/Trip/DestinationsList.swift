//
//  DestinationsList.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/5/22.
//

import SwiftUI

struct DestinationsList: View {
    
    @Binding var destinations: [Destination]
    
    var mainColor: Color
    var accentColor: Color

    @State var listIndex = 1
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    var body: some View {
        List {
            startCell
            forEachDestination
            endCell
        }
        .modifier(ListBackgroundModifier())
        .padding(.leading, 0)
        .padding(.trailing, 20)
        .listStyle(.plain)
        
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
        }
    }
    
    private var startCell: some View {
        let currentTrip = tripLogic.currentTrip
        let startLocation = currentTrip?.startLocation
        let isCurrent = currentTrip?.nextDestinationIndex == 0
        let isCompleted = (currentTrip?.nextDestinationIndex ?? 0) > 0

        return TripDestinationCell(
            mainText: startLocation?.name ?? "",
            subText: startLocation?.address ?? "",
            isCurrent: isCurrent,
            isCompleted: isCompleted,
            isLast: false,
            mainColor: mainColor,
            accentColor: accentColor,
            editable: true)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -0.5, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var forEachDestination: some View {
        let currentTrip = tripLogic.currentTrip
        let endLocation = currentTrip?.endLocation
        let destinations = tripLogic.currentTrip?.destinations.sorted(by: { $0.position < $1.position })

        return ForEach(destinations ?? []) { destination in
            let isCurrent = tripLogic.currentTrip?.nextDestinationIndex == destination.position
            TripDestinationCell(
                mainText: destination.name,
                subText: destination.address,
                isCurrent: isCurrent,
                isCompleted: tripLogic.currentTrip?.completedDestinationsIndices.contains(destination.position) ?? false,
                isLast: endLocation == destination,
                mainColor: mainColor,
                accentColor: accentColor)
        }
        .onDelete(perform: delete(at:))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -0.5, leading: 0, bottom: 0, trailing: 0))
        
    }
    
    private var endCell: some View {
        let currentTrip = tripLogic.currentTrip
        let endLocation = currentTrip?.endLocation
        return TripDestinationCell(
            mainText: endLocation?.name ?? "",
            subText: endLocation?.address ?? "",
            isCurrent: false,
            isCompleted: tripLogic.currentTrip?.completedDestinationsIndices.contains(endLocation?.position ?? 0) ?? false,
            isLast: true,
            mainColor: mainColor,
            accentColor: accentColor,
            editable: true)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -0.5, leading: 0, bottom: 0, trailing: 0))
    }
    
    //MARK: - Methods
    
    private func delete(at offsets: IndexSet) {
        print(offsets)
    }
    
    private func moveRow(_ source: IndexSet, _ destination: Int) {
       destinations.move(fromOffsets: source, toOffset: destination)

        if let oldTrip = tripLogic.currentTrip {
            if let newFirst = destinations.first,
               let newLast = destinations.last {
            let newTrip = Trip(id: oldTrip.id,
                               userID: oldTrip.userID,
                               destinations: destinations,
                               startLocation: newFirst,
                               endLocation: newLast,
                               routes: oldTrip.routes,
                               remainingSteps: oldTrip.remainingSteps,
                               completedStepCount: Int16(oldTrip.completedStepCount),
                               totalStepCount: Int16(oldTrip.totalStepCount),
                               tripState: oldTrip.tripState)
            tripLogic.currentTrip = newTrip
            }
        }
        tripLogic.currentTrip?.destinations.move(fromOffsets: source, toOffset: destination)
    }
}

struct DestinationsList_Previews: PreviewProvider {
    static var previews: some View {
        DestinationsList(destinations: .constant([Destination]()), mainColor: .orange, accentColor: .black)
    }
}
