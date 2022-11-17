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
    
    @StateObject var changeStartStopViewModel = ChangeStartStopViewModel()
    
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    var body: some View {
        HStack {

            imageView
            
            VStack(alignment: .leading) {
                
                if editable {
                    NavigationLink {
                        ChangeStartAndStop(viewModel: changeStartStopViewModel,
                                           errorManager: errorManager)
                            
                    } label: {
                        if #available(iOS 16.0, *) {
                            titleView
                                .underline()
                        } else {
                            titleView
                                
                        }
                    }
                } else {
                    NavigationLink {
                        LD(location: .constant(locationStore.hauntedHotels.first(where: { $0.location.name == mainText }) ?? LocationModel.example),
                           userStore: userStore,
                           firebaseManager: firebaseManager,
                           errorManager: errorManager)
                    } label: {
                        
                        titleView
                    }

                }
                addressView

            }
            .frame(height: 60)
        }
    }
    
    private var titleView: some View {
        Text(mainText)
            .foregroundColor(mainColor)
            .font(.avenirNext(size: 20))
    }
    
    private var addressView: some View {
        Text(subText)
            .foregroundColor(accentColor)
            .font(.avenirNext(size: 17))
            .fontWeight(.light)
    }
    
    private var imageView: some View {
        self.image()
            .resizable()
            .foregroundColor(colors.light)
        
            .frame(width: isCompleted ? 30 : 60, height: isCompleted ? 30 : 60)
            .padding(.horizontal, isCompleted ? 15 : 0)
            .edgesIgnoringSafeArea(.vertical)
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


//MARK: - Preview

struct TripDestinationCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
        TripDestinationCell(
            mainText: "Grand Union Hotel",
            subText: "704 14th St, Fort Benton, MT",
            isCurrent: false,
            isCompleted: true,
            isLast: false,
            mainColor: .orange,
            accentColor: .black,
            editable: true,
            locationStore: LocationStore(),
            errorManager: ErrorManager(),
            userStore: UserStore(),
            firebaseManager: FirebaseManager())
        .listRowSeparator(.hidden)
            TripDestinationCell(
                mainText: "Sacajawea Hotel",
                subText: "5 N Main St, Three Forks, MT",
                isCurrent: true,
                isCompleted: false,
                isLast: false,
                mainColor: .orange,
                accentColor: .black,
                locationStore: LocationStore(),
                errorManager: ErrorManager(),
                userStore: UserStore(),
                firebaseManager: FirebaseManager())
            .listRowSeparator(.hidden)

            TripDestinationCell(
                mainText: "Bourbon Orleans Hotel",
                subText: "717 Orleans St, New Orleans, LA",
                isCurrent: false,
                isCompleted: false,
                isLast: false,
                mainColor: .orange,
                accentColor: .black,
                locationStore: LocationStore(),
                errorManager: ErrorManager(),
                userStore: UserStore(),
                firebaseManager: FirebaseManager())
            .listRowSeparator(.hidden)

            TripDestinationCell(
                mainText: "Stanley Hotel",
                subText: "333 E Wonderview Ave, Estes Park, CO",
                isCurrent: false,
                isCompleted: false,
                isLast: true,
                mainColor: .orange,
                accentColor: .black,
                editable: true,
                locationStore: LocationStore(),
                errorManager: ErrorManager(),
                userStore: UserStore(),
                firebaseManager: FirebaseManager())
            .listRowSeparator(.hidden)

        }
        .modifier(ClearListBackgroundMod())

    }
}
