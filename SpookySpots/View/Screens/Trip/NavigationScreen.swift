////
////  NavigationScreen.swift
////  SpookySpots
////
////  Created by Spencer Belton on 5/10/22.
////
//
//import SwiftUI
//import MapKit
//
//// Maybe delete this and have the navigation just happen all on the trip page since it seesms pretty identical save the step shower at the top and the route helper on trippage. Not sure if i will need to make route helper innaccessible or maybe have it active and showing what route is being tracked ie. 1 ... nah..
//
//struct NavigationScreen: View {
//
//
//    @EnvironmentObject var tripLogic: TripLogic
//
//    @ObservedObject var userStore = UserStore.instance
//
//    let map = MapForTrip()
//
//    var body: some View {
//        ZStack {
//
//            // Map For Navigation
//
//            map
//            VStack{
//                nextStep
//                Spacer()
//
//                HStack {
//                    VStack(alignment: .leading, spacing: 16) {
//                        durationView
//                        distanceView
//                    }
//                    .frame(maxWidth: .infinity)
//                    endButton
//                        .frame(maxWidth: .infinity)
//                        .offset(x: 30)
//                }
//                .padding()
//                .frame(width: UIScreen.main.bounds.width, height:  200)
//                .background(.thickMaterial)
//                .cornerRadius(10)
//            }
//            .edgesIgnoringSafeArea(.bottom)
//
//
//
//        }
//    }
//
//
//
//
//
//    private var distanceView: some View {
//        HStack(spacing: 16) {
//            Text(tripLogic.distanceAsString)
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("miles")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    private var durationView: some View {
//        HStack(spacing: 10) {
//            Text(tripLogic.durationHoursString)
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("hr")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//            Text(tripLogic.durationMinutesString)
//                .font(.avenirNextRegular(size: 23))
//                .fontWeight(.medium)
//            Text("min")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    //MARK: - Buttons
//
//
//
//    private var endButton: some View {
//        Button(action: endTapped) {
//            Text("END")
//                .font(.title)
//                .padding(7)
//        }
//        .buttonStyle(.borderedProminent)
//    }
//
//    //MARK: - Methods
//
//
//    private func endTapped() {
//        // trip logic .end navigation
//    }
//
//
//}
//
//struct NavigationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationScreen()
//            .environmentObject(TripLogic())
//    }
//}
//
///*
//
// start on
// turn left
// turn right
// continue straight
// slight left
// slight right
// merge left
// merge right
// take exit right
// take exit left
// u turn
//
// */
