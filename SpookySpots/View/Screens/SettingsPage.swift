//
//  SettingsPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct SettingsPage: View {
    
    @State var signOutAlertShown = false
    @State var passwordResetAlertShown = false
    @State var firebaseErrorAlertShown = false
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    var body: some View {
        VStack {
            title
            Spacer()
            accountHeader
            accountFunctions
            Spacer()
            signOutButton
        }
        
        .alert("Failed To Sign Out", isPresented: $signOutAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.failToSignOut.rawValue)
        }

        .alert("Email Sent", isPresented: $passwordResetAlertShown) {
            Button("OK", role: .cancel) { }
        }

        .alert("Trouble with Firebase", isPresented: $firebaseErrorAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.firebaseTrouble.rawValue)
        }
        
    }
    
    private var title: some View {
        Text("Settings")
            .font(.title)
            .fontWeight(.light)
    }
    
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
        }
    }
    
    private var accountFunctions: some View {
        VStack(spacing: 15) {
            Button(action: editProfileTapped) { Text("Edit Profile") }
            Button(action: changePasswordTapped) { Text("Change Password")}
        }
    }
    
    private var signOutButton: some View {
        Button(action: signOutTapped) {
            Text("SIGN OUT")
                .fontWeight(.medium)
                .foregroundColor(.red)
        }
    }
    
    //MARK: - Methods
    
    private func editProfileTapped() {
        
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
    
    private func signOutTapped() {
        auth.signOut { error in
            if error == .failToSignOut {
                self.signOutAlertShown = true
            }
        }
    }
    
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
