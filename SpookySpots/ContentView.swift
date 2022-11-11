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
    
    var body: some View {
        ZStack {
            if userStore.isSignedIn {
                TabBarSetup()
            } else {
                CreativeSignInUp()
            }
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
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
