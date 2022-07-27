//
//  LaunchScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 7/26/22.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            purpleBackground
            ghostIcon
        }
    }
    
    private var purpleBackground: some View {
        Color(.purple)
            .ignoresSafeArea()
    }
    
    private var ghostIcon: some View {
        Image("ghost")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .shadow(color: .orange, radius: 1, x: 3, y: 3)
    }
    
    private var curvedTitle: some View {
        Text("SPOOKY SPOTS")
            .font(.avenirNext(size: 22))
            .foregroundColor(.white)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
