//
//  MainLocCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/16/22.
//

import SwiftUI

struct MainLocCell: View {
    
    var location: Location
    
    var body: some View {
        ZStack {
            image
                title
        }.frame(width: 240, height: 270)
        
            
    }
    
    private var image: some View {
        let image: Image
        if let baseImage = location.baseImage {
            image = baseImage
        } else {
            image = Image("bannack")
        }
        return image
            .resizable()
            .aspectRatio(0.9, contentMode: .fill)
            .frame(width: 240, height: 270)
            .cornerRadius(15)
            .shadow(color: .black, radius: 3, x: 0, y: 1.5)
    }
    
    private var title: some View {
        VStack {
            
        Spacer()
        Text(location.name)
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(Color.white)
            .shadow(color: .black, radius: 1, x: 0, y: 2)
            .padding(10)
    }
    }
}

struct MainLocCell_Previews: PreviewProvider {
    static var previews: some View {
        MainLocCell(location: Location.example)
    }
}
