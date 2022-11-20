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
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var loginVM: LoginVM
    
    var auth = Authorization.instance
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack {
            SettingsHeader(settingType: .account)
            List {
                if userStore.isGuest {
                    createAccountButton
                        .listRowSeparator(.hidden)
                        .listRowBackground(weenyWitch.black)
                } else {
                    editProfile
                    manageReviews
                    sendPasswordResetButton
                        .listRowSeparator(.hidden)
                        .listRowBackground(weenyWitch.black)
                    
                    signOutButton
                        .listRowSeparator(.hidden)
                        .listRowBackground(weenyWitch.black)
                }
            }
            .modifier(DisabledScroll())
            .modifier(ClearListBackgroundMod())

            .listStyle(.plain)
            
            .frame(height: userStore.isGuest ? 45 : 160)
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
            Text(K.ErrorHelper.Messages.Auth.failToSignOut.rawValue)
        }
        
        /////MARK: - Password Reset Alert
        .alert("Email Sent", isPresented: $passwordResetAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Password reset sent out to \(userStore.user.email)")
        }
        /////MARK: - Firebase Error Alert
        .alert("Trouble with Firebase", isPresented: $firebaseErrorAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(K.ErrorHelper.Messages.Network.firebaseTrouble.rawValue)
        }
    }
    
    private var editProfile: some View {
        NavigationLink(destination: ProfilePage(userStore: userStore,
                                                errorManager: errorManager,
                                                loginVM: loginVM)) {
            Text("Edit Profile")
                .foregroundColor(weenyWitch.lighter)
                .font(.avenirNext(size: 18))
        }

            .listRowSeparator(.hidden)
            .listRowBackground(weenyWitch.black)
    }
    
    private var manageReviews: some View {
        NavigationLink(destination: ManageReviews(firebaseManager: firebaseManager,
                                                  userStore: userStore,
                                                  locationStore: locationStore,
                                                  errorManager: errorManager)) {
            Text("Manage Reviews")
                .foregroundColor(weenyWitch.lighter)
                .font(.avenirNext(size: 18))
        }

            .listRowSeparator(.hidden)
            .listRowBackground(weenyWitch.black)
    }
    
    //MARK: - Buttons
    private var sendPasswordResetButton: some View {
        Button(action: changePasswordTapped) {
            Text("Change Password")
                .foregroundColor(weenyWitch.lighter)
                .font(.avenirNext(size: 18))
        }
    }
    
    private var signOutButton: some View {
        Button(action: signOutTapped) {
            Text("SIGN OUT")
                .font(.avenirNext(size: 17))
                .fontWeight(.light)
                .foregroundColor(weenyWitch.lighter)
        }
    }

    private var createAccountButton: some View {
        Button(action: createAccountTapped) {
            Text("Create Account")
                .font(.avenirNext(size: 17))
                .foregroundColor(weenyWitch.lighter)
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
    
    private func createAccountTapped() {
        userStore.isSignedIn = false
        userStore.user = User()
        UserDefaults.standard.set(false, forKey: K.UserDefaults.isGuest)

    }

}


struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account(userStore: UserStore(),
                firebaseManager: FirebaseManager(),
                locationStore: LocationStore(),
                errorManager: ErrorManager(),
                loginVM: LoginVM())
    }
}
