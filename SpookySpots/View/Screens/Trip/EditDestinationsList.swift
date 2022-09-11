////
////  EditDestinationsList.swift
////  SpookySpots
////
////  Created by Spencer Belton on 9/5/22.
////
//
//import SwiftUI
//
//struct EditDestinationsList: View {
//    
//    @Binding var destinations: [Destination]
//        
//    @ObservedObject var tripLogic = TripLogic.instance
//    
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//    
//    private var list: some View {
//        ForEach(destinations) { destination in
//            Text(destination.name)
//        }
//        .onDelete(perform: delete(at:))
//        .onMove(perform: moveRow(_:_:))
//
//    }
//    
//
//}
//
//struct EditDestinationsList_Previews: PreviewProvider {
//    static var previews: some View {
//        let destinations = [Destination]()
//        EditDestinationsList(destinations: .constant(destinations))
//    }
//}
