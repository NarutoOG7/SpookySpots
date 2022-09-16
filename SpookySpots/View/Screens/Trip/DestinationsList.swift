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

    
    @ObservedObject var tripLogic = TripLogic.instance
    
    var body: some View {
        List {
            startCell
            forEachDestination
            endCell
        }
        .padding(.leading, 0)
        .padding(.trailing, 20)
        .listStyle(.plain)
    }
    
    private var startCell: some View {
        let currentTrip = tripLogic.currentTrip
        let startLocation = currentTrip?.startLocation
        return TripDestinationCell(
            mainText: startLocation?.name ?? "",
            subText: startLocation?.address ?? "",
            isCurrent: tripLogic.currentTrip?.recentlyCompletedDestination?.name == startLocation?.name,
            isCompleted: tripLogic.currentTrip?.completedDestinations.contains(startLocation ?? Destination()) ?? false,
            isLast: false,
            mainColor: mainColor,
            accentColor: accentColor,
            editable: true)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var forEachDestination: some View {
        let currentTrip = tripLogic.currentTrip
        let endLocation = currentTrip?.endLocation
        return ForEach(tripLogic.currentTrip?.destinations ?? []) { destination in
            TripDestinationCell(
                mainText: destination.name,
                subText: destination.address,
                isCurrent: tripLogic.currentTrip?.recentlyCompletedDestination == destination,
                isCompleted: tripLogic.currentTrip?.completedDestinations.contains(destination) ?? false,
                isLast: endLocation == destination,
                mainColor: mainColor,
                accentColor: accentColor)
        }
        .onDelete(perform: delete(at:))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
        
    }
    
    private var endCell: some View {
        let currentTrip = tripLogic.currentTrip
        let endLocation = currentTrip?.endLocation
        return TripDestinationCell(
            mainText: endLocation?.name ?? "",
            subText: endLocation?.address ?? "",
            isCurrent: false,
            isCompleted: tripLogic.currentTrip?.completedDestinations.contains(endLocation ?? Destination()) ?? false,
            isLast: true,
            mainColor: mainColor,
            accentColor: accentColor,
            editable: true)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
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
                               isActive: oldTrip.isActive,
                               destinations: destinations,
                               startLocation: newFirst,
                               endLocation: newLast,
                               routes: oldTrip.routes)
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
