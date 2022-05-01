//
//  BorderedCircularButton.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/28/22.
//

import SwiftUI

struct BorderedCircularButton: View {
    
    var image: Image
    var title: String
    var color: Color
    var tapped: () -> ()
    
    let imageSize = 26.0
    let minusImageSize = 3.0
    let extraPadding = 11.5
    
    var body: some View {
        Button(action: tapped) {
            VStack(alignment: .center) {
            image
                .resizable()
                .tint(.green)
                .frame(
                    width: imageSize,
                    height: imageIsSystemMinus() ? minusImageSize : imageSize)
                .padding()
                .padding(.vertical, imageIsSystemMinus() ? extraPadding : 0)
                .background(
                    Circle().tint(.white).padding(2)
                        .background(
                            Circle().tint(.green)))
                
                Text(title)
                    .foregroundColor(color)
                    .font(.avenirNextRegular(size: 13))
                    .frame(width: 70)
                
            }
        }
    }
    
    private func imageIsSystemMinus() -> Bool {
        image == Image(systemName: "minus")
    }
    
    
}


struct BorderedCircularButton_Previews: PreviewProvider {
    static var previews: some View {
        BorderedCircularButton(
            image: Image(systemName: "minus"),
            title: "Remove From Trip",
            color: .green) {/* action */}
    }
}
