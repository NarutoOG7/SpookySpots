//
//  ContentView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var userStore = UserStore.instance

    var body: some View {
        if userStore.isSignedIn {
            TabBarSetup()
        } else {
            CreativeSignInUp()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
