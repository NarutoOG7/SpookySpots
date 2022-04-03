//
//  LocationPreviewOnMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI


struct LocationPreviewOnMap: View {
    
    let location: Location
    
    @ObservedObject var tripPageVM = TripPageVM.instance

    
    var body: some View {
        ZStack {
            
            image
            HStack {
                spacer
                VStack(alignment: .leading) {
                    title
                    address
                    Spacer()
                    milesAway
                }.padding()
                    .background(Color(red: 111 / 255, green: 30 / 255, blue: 81 / 255))
//                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 5)

                
            }         .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 5)

            favoriteButton
            addToTripButton
              
        }
//        .padding()
        .cornerRadius(25)
        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 5)
        .background(RoundedRectangle(cornerRadius: 25.0))

        
    }
    
    //MARK: - SubViews
    
    private var image: some View {
        let img: Image
        if let image = location.baseImage {
            img = image
        } else {
            img = Image("Bannack")
        }
        return HStack {
        img
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 200)
                .offset(x: -35)
            Spacer()
        }
    }
    
    private var title: some View {
        Text(location.name)
            .font(.title3)
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(Color(red: 18/255, green: 203/255, blue: 196/255))
            .padding(.vertical, 5)

    }
    
    private var address: some View {
        Text(location.address?.streetCityState() ?? "")
            .font(.subheadline)
            .foregroundColor(Color(red: 153/255, green: 128/255, blue: 250/255))
            .lineLimit(2)
            .padding(.trailing)
            .padding(.bottom, 8)
    }
    
    private var milesAway: some View {

        Text(String(format: "%.0f miles", location.distanceToUser ?? 0))
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(Color(red: 153/255, green: 128/255, blue: 250/255))
        
    }
    
    private var spacer: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.clear)
            .frame(width: 143)
    }
    //MARK: - Buttons
    
    private var favoriteButton: some View {
        HStack {
            VStack {
        CircleButton(size: .small,
                     image: Image(systemName: "heart"),
                     outlineColor: .white,
                     iconColor: .gray,
                     backgroundColor: .white,
                     clicked: favoriteTapped)
                Spacer()
            }
            Spacer()
        } .offset(x: 5, y: 5)
    }
    
    private var addToTripButton: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                StackedCircleButton(
                    size: .small,
                    mainImage: isInTrip() ? Image(systemName: "map.fill") : Image(systemName: "map"),
                    secondaryImage: isInTrip() ? Image(systemName: "minus") : Image(systemName: "plus"),
                    outlineColor: .white,
                    iconColor: .white,
                    backgroundColor: .blue,
                    clicked: addOrSubtractFromTrip)
            }
        }
//        }.offset(x: 17, y: 17)
     }
    
    
    //MARK: - Methods
    
    private func favoriteTapped() {
        
    }
    
    private func isInTrip() -> Bool {
        tripPageVM.trip?.listContainsLocation(location: location) ?? false
    }
    
    private func addOrSubtractFromTrip() {
        tripPageVM.trip?.addOrSubtractFromTrip(location: location)
    }
    
}

struct LocationPreviewOnMap_Previews: PreviewProvider {
    static var previews: some View {
        LocationPreviewOnMap(location: Location.example)
    }
}
