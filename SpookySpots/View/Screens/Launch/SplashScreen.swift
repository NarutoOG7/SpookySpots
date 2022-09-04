//
//  SplashScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/13/22.
//

import SwiftUI

struct SplashScreen: View {
    
    var body: some View {
        ZStack {
            K.Colors.WeenyWitch.black
                .edgesIgnoringSafeArea(.all)
            K.Images.logo
                .padding(.bottom, 110)
                
        }
    }

}




//MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .previewInterfaceOrientation(.portrait)
    }
}


