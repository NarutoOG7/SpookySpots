//
//  Auth.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/13/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


enum AuthErrorTypes: String {
    case incorrectEmailOrPassword = "Email or Password is invalid"
    case passwordsDontMatch = "Passwords DO NOT match"
    case firebaseTrouble = "There was an issue creating your account."
    case emailInUse = "This email is already in use."
    case failedToSaveUser = "There was a problem saving the user"
    case troubleConnectingToFirebase = "There seems to be an issue with the connection to firebase."
    case failToSignOut = "There was an error signing out of your account. Check your connection and try again."
}

class Authorization {
    
    static let instance = Authorization()
    
    @ObservedObject var userStore = UserStore.instance
    
    let auth = Auth.auth()
    
    
    func isUserAlready(id: String) -> Bool {
        id == auth.currentUser?.uid
    }
    
    func isSignedIn() -> Bool {
        auth.currentUser != nil
    }
    
    func signIn(email: String, password: String, error onError: @escaping(AuthErrorTypes) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                print(error.localizedDescription)
                onError(.firebaseTrouble)
            }
            
            if let result = authResult {
            
                let user = User(id: result.user.uid, name: result.user.displayName ?? "", email: result.user.email ?? "")
                
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(user)
                    
                    UserDefaults.standard.set(data, forKey: "user")
                } catch {
                    print(AuthErrorTypes.failedToSaveUser.rawValue)
                    onError(.failedToSaveUser)
                }
                
                DispatchQueue.main.async {
                    self.userStore.isSignedIn = true
                    self.userStore.user = user
                    UserDefaults.standard.set(true, forKey: "signedIn")

                }
            }
        }
    }
    
    func signUp(userName: String, email: String, password: String, confirmPassword: String, error onError: @escaping(AuthErrorTypes) -> Void) {
        //Todo: confirm that password and confirm password match
        
        if confirmPassword == password {
        
        auth.createUser(withEmail: email, password: password) { (result, error) in
                
            if let error = error {
                if error.localizedDescription.contains("email in use") {
                    print("Its in use")
                    onError(.emailInUse)
                } else {
                print("Trouble creating account \(error)")
                    onError(.firebaseTrouble)
                }
            } else {
                guard let result = result else {
                    print("No result")
                    onError(.firebaseTrouble)
                    return
                }
                
                let user = User(id: result.user.uid, name: userName, email: result.user.email ?? "")
                
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(user)
                    
                    UserDefaults.standard.set(data, forKey: "user")
                } catch {
                    print(AuthErrorTypes.failedToSaveUser.rawValue)
                    onError(.failedToSaveUser)
                }
                
                DispatchQueue.main.async {
                    self.userStore.isSignedIn = true
                    self.userStore.user = user
                    UserDefaults.standard.set(true, forKey: "signedIn")

                }
                
                
            }
        }
        
        setCurrentUsersName(userName)
            
        } else {
            onError(.passwordsDontMatch)
        }
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
    
    
    //MARK: - SignOut
    func signOut(error onError: @escaping(AuthErrorTypes) -> Void) {
        do {
            try auth.signOut()
            self.userStore.isSignedIn = false
        } catch {
            print("Trouble siging out. \(error)")
            // handle error
            onError(.failToSignOut)
        }
    }
    
    //MARK: - GuestSignIn
    func anonymousSignIn(error onError: @escaping(AuthErrorTypes) -> Void) {
        auth.signInAnonymously { result, error in
            if let error = error {
                print(error.localizedDescription)
                onError(.troubleConnectingToFirebase)
            }
            if result != nil {
                DispatchQueue.main.async {
                    self.userStore.isSignedIn = true
                    self.userStore.isGuest = true
                    UserDefaults.standard.set(true, forKey: "signedIn")
                }
            }
        }
    }
    
    //MARK: - PasswordReset
    func passwordReset(email: String, withCompletion completion: @escaping(Bool) -> Void, error onError: @escaping(AuthErrorTypes) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print(error.localizedDescription)
                onError(.firebaseTrouble)
            } else {
                completion(true)
            }
        }
    }
}