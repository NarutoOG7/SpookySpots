//
//  TripDestinationCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/5/22.
//

import SwiftUI

struct TripDestinationCell: View {
    
    let mainText: String
    let subText: String
    let isCurrent: Bool
    let isCompleted: Bool
    let isLast: Bool
    
    let mainColor: Color
    let accentColor: Color
    
    var editable: Bool = false
    
    private let images = K.Images.Trip.self
    private let colors = K.Colors.WeenyWitch.self
    
    @ObservedObject var locationStore = LocationStore.instance
    
    var body: some View {
        HStack {
            self.image()
                .resizable()
            
                .frame(width: isCompleted ? 30 : 60, height: isCompleted ? 30 : 60)
                .padding(.horizontal, isCompleted ? 15 : 0)
            .edgesIgnoringSafeArea(.vertical)
            
            
            VStack(alignment: .leading) {
                
                if editable {
                    NavigationLink {
                        ChangeStartAndStop()
                    } label: {
                        Text(mainText)
                            .foregroundColor(mainColor)
                            .font(.avenirNext(size: 20))
                            .underline()
                    }
                } else {
                    NavigationLink {
                        LD(location: .constant(locationStore.hauntedHotels.first(where: { $0.location.name == mainText }) ?? LocationModel.example))
                    } label: {
                        
                        Text(mainText)
                            .foregroundColor(mainColor)
                            .font(.avenirNext(size: 20))
                    }

                }
                
                Text(subText)
                    .foregroundColor(accentColor)
                    .font(.avenirNext(size: 17))
                    .fontWeight(.light)
            }
            .frame(height: 60)
            
        }
    }
    
    private func image() -> Image {
        // if is completed
        isCompleted ? images.completed :
        // if is current
        (isCurrent ? images.currentLocationIconWithDots :
        // if is last
        (isLast ? images.lastDestinationIcon :
        // otherwise
        images.destinationIcon))
    }
}


struct TripDestinationCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
        TripDestinationCell(
            mainText: "Home",
            subText: "906 Richmond Dr, Fort Collins, CO",
            isCurrent: false,
            isCompleted: true,
            isLast: false,
            mainColor: .orange,
            accentColor: .black,
            editable: true)
        .listRowSeparator(.hidden)
            TripDestinationCell(
                mainText: "Bozeman",
                subText: "607 Professional Dr, Bozeman, MT",
                isCurrent: true,
                isCompleted: false,
                isLast: false,
                mainColor: .orange,
                accentColor: .black)
            .listRowSeparator(.hidden)

            TripDestinationCell(
                mainText: "Childhood Home",
                subText: "425 8th Street, Steamboat Springs, CO",
                isCurrent: false,
                isCompleted: false,
                isLast: false,
                mainColor: .orange,
                accentColor: .black)
            .listRowSeparator(.hidden)

            TripDestinationCell(
                mainText: "Mom and Dad's Place",
                subText: "49915 RCR 129, eSteamboat Springs, CO",
                isCurrent: false,
                isCompleted: false,
                isLast: true,
                mainColor: .orange,
                accentColor: .black,
                editable: true)
            .listRowSeparator(.hidden)

        }
    }
}
