//
//  ColorBar.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct ColorBar: View {

    @EnvironmentObject var tripLogic: TripLogic

    var position: Int?
    var title: String?
    var color: Color
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        HStack {
          titleView
            colorBar

        }
        .overlay(background.padding(-7))
        .onTapGesture(perform: onTapped)
    }

    private var titleView: some View {
        Text(title ?? "")
            .foregroundColor(weenyWitch.brown)
            .font(.avenirNext(size: 18))
    }
    
    private var colorBar: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color)
            .frame(width: 50, height: 12)
    }
    
    //MARK: - Background
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 2)
            .fill(isSelected() ? .orange : .clear)
    }

    //MARK: - Methods

    private func isSelected() -> Bool {
        
        if let position = position {
            
            return tripLogic.positionIsSelected(position)
        }
        return false
    }

    private func onTapped() {
        
        if let position = position {
            
            tripLogic.selectAlternate(position)
        }
        tripLogic.alternateRouteState = .selected
    }
}


struct ColorBar_Previews: PreviewProvider {
    static var previews: some View {
        ColorBar(color: Color.red)
    }
}
