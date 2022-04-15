//
//  ContentView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var userStore = UserStore.instance
//    init() {
//        userStore.isSignedIn = Authorization.instance.isSignedIn()
//    }

    var body: some View {
        
//        if UserDefaults.standard.object(forKey: "user_uid_key") != nil {
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
