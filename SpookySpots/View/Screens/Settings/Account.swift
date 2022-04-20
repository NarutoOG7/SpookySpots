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
    @State var deleteAcctAlertShown = false
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    var body: some View {
        VStack {
            SettingsHeader(settingType: .account)
            List {
                NavigationLink("Edit Profile", destination: ProfilePage())
                    .listRowSeparator(.hidden)
                sendPasswordResetButton
                    .listRowSeparator(.hidden)
                signOutOrDeleteButton
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .frame(height: 230)
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
        
        /////MARK: - Delete Account Confirmation Alert
        .alert("Are You Sure?", isPresented: $deleteAcctAlertShown) {
            Button(role: .destructive, action: confirmDeleteTapped) {
                Text("DELETE")
            }
            Button("CANCEL", role: .cancel) { }
        }
    }
    
    //MARK: - Buttons
    private var sendPasswordResetButton: some View {
        Button(action: changePasswordTapped) {
            Text("Change Password")
        }
    }
    
    private var signOutButton: some View {
        Button(action: signOutTapped) {
            Text("SIGN OUT")
                .font(.callout)
                .fontWeight(.light)
                .foregroundColor(.red)
        }
    }
    
    private var signOutOrDeleteButton: some View {
        HStack {
            signOutButton
            Spacer()
            deleteAcctButton
        }
    }
    
    private var deleteAcctButton: some View {
        HStack {
            Spacer()
            Spacer()
        Button(action: deleteAcctTapped) {
            Text("Delete Account")
                .font(.callout)
                .fontWeight(.light)
                .foregroundColor(Color.gray)
        }.padding(.horizontal)
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
        }
    }
    
    private func deleteAcctTapped() {
        self.deleteAcctAlertShown = true
    }
    
    private func confirmDeleteTapped() {
        auth.deleteUserAccount { error in
            self.deleteAcctAlertShown = true
        } success: { result in
            if result == true {
                
            }
        }
    }
}


struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account()
    }
}
