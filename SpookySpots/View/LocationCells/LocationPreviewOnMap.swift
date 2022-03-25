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
            
        HStack {
                image
            VStack(alignment: .leading, spacing: 12) {
                title
                address
                
                HStack {
                milesAway
                    Spacer()
                    addToTripButton
                }.frame(height: 40)
            }
        }
        .cornerRadius(25)
        .background(RoundedRectangle(cornerRadius: 25.0))
        .shadow(color: .black, radius: 3, x: 0.5, y: 0.5)
        .padding()
            
            HStack {
                favoriteButton
                Spacer()
            }
        }
        
    }
    
    //MARK: - SubViews
    private var image: some View {
        Image("bannack")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width / 2.7)
        
    }
    
    private var title: some View {
        Text(location.name)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(Color(#colorLiteral(red: 0.6526787877, green: 0.9948721528, blue: 1, alpha: 1)))
            .padding(.horizontal, 5)
    }
    
    private var address: some View {
        Text(location.address?.streetCityState() ?? "")
            .font(.subheadline)
            .foregroundColor(Color(#colorLiteral(red: 0.4834827094, green: 0.4834827094, blue: 0.4834827094, alpha: 1)))
            .padding(.trailing)
            .padding(.bottom, 8)
    }
    
    private var milesAway: some View {
        Text(String(format: "%.0f miles", location.distanceToUser ?? 0))
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(Color(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)))
            .offset(y: 17)
    }
    
    //MARK: - Buttons
    
    private var favoriteButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "heart"),
                     outlineColor: .white,
                     iconColor: .gray,
                     backgroundColor: .white,
                     clicked: favoriteTapped)
            .offset(x: 23, y: -48)
    }
    
    private var addToTripButton: some View {
            VStack {
                StackedCircleButton(
                    size: .small,
                    mainImage: isInTrip() ? Image(systemName: "map.fill") : Image(systemName: "map"),
                    secondaryImage: isInTrip() ? Image(systemName: "minus") : Image(systemName: "plus"),
                    outlineColor: .white,
                    iconColor: .white,
                    backgroundColor: .blue,
                    clicked: addOrSubtractFromTrip)
            }
            .frame(width: 100, height: 100)
            .offset(x: 14, y: 4)
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
