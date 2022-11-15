//
//  SettingsPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct SettingsPage: View {
    
    @State var passwordResetAlertShown = false
    @State var firebaseErrorAlertShown = false
    @State var failSignOutAlertShown = false
    @State var confirmSignOutAlertShown = false
    
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                Account()
                About()
                Admin()
                addLocationView
                        .padding(.top, -30)
            }
            .padding(.vertical, 30)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
            .background(weenyWitch.black)
    }
      
    //MARK: - Add Location
    private var addLocationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Know of any spooky locations that you would like to share?")
                .foregroundColor(weenyWitch.light)
                .font(.avenirNextRegular(size: 18))
                .italic()
            NavigationLink {
                AddLocationView()
            } label: {
                Text("Submit basic information")
                    .foregroundColor(weenyWitch.orange)
                    .font(.avenirNextRegular(size: 18))
                    .underline()
            }

        }
        .padding(.horizontal)
    }
    
}

//MARK: - Preview
struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsPage()
        }
    }
}
