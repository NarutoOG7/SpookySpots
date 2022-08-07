//
//  PastTrips.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/1/22.
//

import SwiftUI


struct PastTrips: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: CDTrip.entity(), sortDescriptors: []) var trips: FetchedResults<CDTrip>

//    @FetchRequest(fetchRequest: CDTrip) var cdTripBucket: FetchedResults<CDTrip>

    
    
//    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        tripsList
        
            .navigationTitle("Past Trips")
    }
    
    private var tripsList: some View {
        List(trips) { trip in
            if let destinations = trip.destinations?.allObjects as? [CDDestination] {
                
//            if let destinations = trip.destinations?.allObjects as? [CDDestination] {
//
                Text(destinations.first?.name ?? "blank")
                    .foregroundColor(.red)
            }
        }
    }
    
    
    
}

//MARK: - Previews
struct PastTrips_Previews: PreviewProvider {
    static var previews: some View {
        PastTrips()
    }
}
