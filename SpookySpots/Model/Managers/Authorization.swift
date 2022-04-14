//
//  Auth.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/13/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class Authorization {
    static let instance = Authorization()
    
    @ObservedObject var userStore = UserStore.instance
    
    let auth = Auth.auth()
    
    func signIn(email: String, password: String) {
        
        auth.signIn(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let result = authResult {
            
                let user = User(id: result.user.uid, name: result.user.displayName ?? "", email: result.user.email ?? "")
                
                DispatchQueue.main.async {
                    self.userStore.isSignedIn = true
                    self.userStore.user = user
                }
            }
        }
    }
    
    func signUp(userName: String, email: String, password: String, confirmPassword: String) {
        //Todo: confirm that password and confirm password match
        auth.createUser(withEmail: email, password: password) { (result, error) in
                
            if let error = error {
                print("Trouble creating account \(error)")
            } else {
                guard let result = result else {
                    print("No result")
                    return
                }
                
                let user = User(id: result.user.uid, name: userName, email: result.user.email ?? "")
                
                DispatchQueue.main.async {
                    self.userStore.isSignedIn = true
                    self.userStore.user = user
                }
                
                
            }
        }
        
        setCurrentUsersName(userName)
    }
    
    
    func setCurrentUsersName(_ name: String) {
        if let currentUser = auth.currentUser {
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.displayName = name
            
            changeRequest.commitChanges { error in
                if let error = error {
                    print(error.localizedDescription)
                    // handle
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.userStore.isSignedIn = false
        } catch {
            print("Trouble siging out. \(error)")
            // handle error
        }
    }
}
