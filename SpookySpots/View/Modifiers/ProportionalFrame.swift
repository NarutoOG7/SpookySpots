//
//  ProportionalFrame.swift
//  SpookySpots
//
//  Created by Spencer Belton on 10/23/22.
//

import SwiftUI


extension View {
    
    func proportionalPadding(geo: GeometryProxy, widthRatio: CGFloat, heightRatio: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let width = geo.size.width * widthRatio
        let height = geo.size.height * heightRatio
        return (width, height)
    }
}
