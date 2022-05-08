////
////  TripPage.swift
////  SpookySpots
////
////  Created by Spencer Belton on 5/7/22.
////
//
//import SwiftUI
//
//struct TripPage: View {
//    var body: some View {
//        
//        ZStack {
//            
//            MapForTrip()
//            
//            VStack {
//                
//                HStack {
//                    
//                    VStack {
//                        distanceView
//                        durationView
//                    }
//                    
//                    goOrGetRoutesButton
//                    
//                }
//                
//                
//            }
//        }
//    }
//    
//    private var distanceView: some View {
//        HStack {
//            Text("233")
//                .font(.avenirNextRegular(size: 17))
//                .fontWeight(.bold)
//            Text("mi")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
//    
//    private var durationView: some View {
//        HStack {
//            Text("4")
//                .font(.avenirNextRegular(size: 17))
//                .fontWeight(.bold)
//            Text("hr")
//                .font(.avenirNextRegular(size: 15))
//                .fontWeight(.bold)
//                .foregroundColor(.secondary)
//        }
//    }
//    
//    private var startEnd: some View {
//        VStack {
//            
//            HStack {
//                Text("START:")
//                    .font(.avenirNextRegular(size: 15))
//                    .fontWeight(.bold)
//                    .foregroundColor(.secondary)
//                startLink
//            }
//            
//            HStack {
//                Text("END:")
//                    .font(.avenirNextRegular(size: 15))
//                    .fontWeight(.bold)
//                    .foregroundColor(.secondary)
//                endLink
//            }
//        }
//    }
//    
//    //MARK: - Buttons/Links
//    
//    private var goOrGetRoutesButton: some View {
//        Button(action: goOrGetTapped) {
//            Text("Get Routes")
//        }
//        .buttonStyle(.borderedProminent)
//    }
//    
//    private var startLink: some View {
//        NavigationLink {
//            ChangeStartAndStop()
//        } label: {
//            
//        }
//    }
//    
//    private var endLink: some View {
//        NavigationLink {
//            ChangeStartAndStop()
//        } label: {
//            
//        }
//    }
//    
//    //MARK: - Methods
//    
//    private func goOrGetTapped() {
//        
//    }
//    
//}
//
//struct TripPage_Previews: PreviewProvider {
//    static var previews: some View {
//        TripPage()
//    }
//}
