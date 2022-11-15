//
//  ContentView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var showSplash = true
        
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if userStore.isSignedIn {
                    TabBarSetup()
                } else {
                    CreativeSignInUp()
                }
                
                splashScreen
                
                errorBanner
                    .offset(y: geo.size.height / 9)
                
            }
        }
        
    }
    
    private var splashScreen: some View {
        SplashScreen()
          .opacity(showSplash ? 1 : 0)

          .task {
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation() {
                  self.showSplash = false
                }
              }
          }
    }
    
    private var errorBanner: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return NotificationBanner(message: $errorManager.message,
                                  isVisible: $errorManager.shouldDisplay)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
