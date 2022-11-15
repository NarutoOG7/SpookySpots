//
//  Admin.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/14/22.
//

import SwiftUI

struct Admin: View {
    
    @ObservedObject var userStore = UserStore.instance
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        if userStore.user.id == K.adminKey {
            adminView
        }
    }
    
    private var adminView: some View {
        VStack {
            SettingsHeader(settingType: .admin)
            List {
                NavigationLink(destination: DatabaseView()) {
                    Text("Database")
                        .font(.avenirNext(size: 18))
                        .foregroundColor(weenyWitch.lighter)
                    
                }.listRowSeparator(.hidden)
                    .listRowBackground(weenyWitch.black)
            }
            .modifier(ClearListBackgroundMod())
            .frame(minHeight: 50)
            .listStyle(.plain)
        }
    }
}

struct Admin_Previews: PreviewProvider {
    static var previews: some View {
        Admin()
    }
}
