//
//  ContentView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authorization = Authorization.instance
    init() {
            authorization.signedIn = authorization.isSignedIn
    }
    
    var body: some View {
        Login()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
