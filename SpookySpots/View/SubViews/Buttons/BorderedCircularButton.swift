//
//  BorderedCircularButton.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/28/22.
//

import SwiftUI

struct BorderedCircularButton: View {
    
    var image: Image
    var color: Color
    var tapped: () -> ()
    
    var body: some View {
        
        Button(action: tapped) {
            image
                .tint(.green)
                .padding()
                .background(Circle().tint(.white).padding(2).background(Circle().tint(.green)))
        }
    }
}


struct BorderedCircularButton_Previews: PreviewProvider {
    static var previews: some View {
        BorderedCircularButton(image: Image(systemName: "plus"), color: .green) {
            
        }
    }
}
