//
//  Account.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/16/22.
//

import SwiftUI

struct Account: View {
    
    @State var passwordResetAlertShown = false
    @State var failSignOutAlertShown = false
    @State var confirmSignOutAlertShown = false
    @State var firebaseErrorAlertShown = false
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    var body: some View {
        VStack {
            SettingsHeader(settingType: .account)
            List {
                NavigationLink(destination: ProfilePage()) {
                    Text("Edit Profile")
                        .foregroundColor(K.Colors.WeenyWitch.lighter)
                }

                    .listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
                sendPasswordResetButton
                    .listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
                signOutButton
                    .listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
            }
            .listStyle(.plain)
            
            .frame(height: 160)
        }
        /// //MARK: - Confirm Sign Out Alert
        .alert("Sign Out?", isPresented: $confirmSignOutAlertShown) {
            Button(role: .destructive, action: confirmSignOutTapped) {
                Text("SIGN OUT")
            }
            Button("CANCEL", role: .cancel) { }
        }
        /////MARK: - Sign Out Error Alert
        .alert("Failed To Sign Out", isPresented: $failSignOutAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.failToSignOut.rawValue)
        }
        
        /////MARK: - Password Reset Alert
        .alert("Email Sent", isPresented: $passwordResetAlertShown) {
            Button("OK", role: .cancel) { }
        }
        /////MARK: - Firebase Error Alert
        .alert("Trouble with Firebase", isPresented: $firebaseErrorAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.firebaseTrouble.rawValue)
        }
    }
    
    //MARK: - Buttons
    private var sendPasswordResetButton: some View {
        Button(action: changePasswordTapped) {
            Text("Change Password")
                .foregroundColor(K.Colors.WeenyWitch.lighter)
        }
    }
    
    private var signOutButton: some View {
        Button(action: signOutTapped) {
            Text("SIGN OUT")
                .font(.callout)
                .fontWeight(.light)
                .foregroundColor(K.Colors.WeenyWitch.lighter)
//                .foregroundColor(.red)
        }
    }
  
    
    //MARK: - Methods
    
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
        self.confirmSignOutAlertShown = true
    }
    
    
    private func confirmSignOutTapped() {
        auth.signOut { error in
            if error == .failToSignOut {
                self.failSignOutAlertShown = true
            }
            userStore.user = User()
        }
    }
    

}


struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account()
    }
}
