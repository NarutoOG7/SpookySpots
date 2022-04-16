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
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
            title
                accountHeader
                accountFunctions
                aboutHeader
                aboutFunctions
                Spacer(minLength: 160)
            }.offset(y: -40)

        .alert("Email Sent", isPresented: $passwordResetAlertShown) {
            Button("OK", role: .cancel) { }
        }

        .alert("Trouble with Firebase", isPresented: $firebaseErrorAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.firebaseTrouble.rawValue)
        }
        }
    }
    
    private var title: some View {
        Text("Settings")
            .font(.title)
            .fontWeight(.thin)
            .padding(.horizontal)
    }
    
    //MARK: - Account
    private var accountHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.pink)
                Text("Account")
                    .font(.title3)
                    .fontWeight(.semibold)
            }.padding(.horizontal)
            Rectangle()
                .fill(.black)
                .frame(height: 1)
                .padding(.horizontal)
        }.padding(.top, 30)
    }
    private var accountFunctions: some View {
        List {
            NavigationLink("Edit Profile", destination: ProfilePage())
                .listRowSeparator(.hidden)
            sendPasswordResetButton
                .listRowSeparator(.hidden)

        }
        .listStyle(.plain)
    }
    private var sendPasswordResetButton: some View {
        Button(action: changePasswordTapped) {
            Text("Change Password")
        }
    }
    private func sendPasswordReset() {
        auth.passwordReset(email: userStore.user.email) { result in
            if result == true {
                self.passwordResetAlertShown = true
            }
        } error: { error in
            if error == .firebaseTrouble {
                firebaseErrorAlertShown = true
            }
        }

    }
    private func changePasswordTapped() {
        auth.passwordReset(email: userStore.user.email) { result in
            if result == true {
                self.passwordResetAlertShown = true
            }
        } error: { error in
            if error == .firebaseTrouble {
                self.firebaseErrorAlertShown = true
            }
        }
        
    }
    
    //MARK: - About
    private var aboutHeader: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.pink)
                    Text("About")
                        .font(.title3)
                        .fontWeight(.semibold)
                }.padding(.horizontal)
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)
                    .padding(.horizontal)
            }
        }
    private var aboutFunctions: some View {
        List {
            NavigationLink("Rate SpookySpots", destination: RateMyApp())
                .listRowSeparator(.hidden)

            NavigationLink("Follow us on Facebook", destination: FacebookPage())
                .listRowSeparator(.hidden)

            NavigationLink("Privacy Policy", destination: PrivacyPolicyPage())
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
//        EditProfilePage()
    }
    
}


struct RateMyApp: View {
    var body: some View {
        Text("Thanks")
    }
}
          
struct FacebookPage: View {
    var body: some View {
        Text("Facebook")
    }
}
                
struct PrivacyPolicyPage: View {
    var body: some View {
        Text("Here are the terms and conditions")
    }
}

