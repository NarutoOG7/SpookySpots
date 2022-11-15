//
//  LoginSignupViewModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/14/22.
//

import SwiftUI


class SignupVM: ObservableObject {
    
    static let instance = SignupVM()
    
    @Published var usernameInput = ""
    @Published var emailInput = ""
    @Published var passwordInput = ""
    @Published var confirmPasswordInput = ""
    
    
    //MARK: - Error Message Helpers
    @Published var shouldShowUserNameErrorMessage = false
    @Published var shouldShowEmailErrorMessage = false
    @Published var shouldShowPasswordErrorMessage = false
    @Published var shouldShowConfirmPasswordError = false
    @Published var shouldShowFirebaseError = false

    @Published var emailErrorMessage = ""
    @Published var usernameErrorMessage = ""
    @Published var passwordErrorMessage = ""
    @Published var confirmPasswordErrorMessage = ""
    @Published var firebaseErrorMessage = ""
    
    @ObservedObject var network = NetworkManager()

    var auth = Authorization()

    func signupTapped() {
        
        guard isConnectedToNetwork() else {
            setErrorMessage(.firebase, message: "Please check your network connection and try again.")
            return
        }
        
        checkForErrorAndSendAppropriateErrorMessage()
        
        if fieldsAreFilled() {
            auth.signUp(userName: usernameInput,
                        email: emailInput,
                        password: passwordInput,
                        confirmPassword: confirmPasswordInput) { error in
                self.handleError(error)
            }
        }
        
    }
    
    private func fieldsAreFilled() -> Bool {
        usernameInput != "" &&
        emailInput != "" &&
        passwordInput != "" &&
        confirmPasswordInput != ""
    }
    
    func isConnectedToNetwork() -> Bool {
        network.connected
    }
    

    //MARK: - Errors
    
    private func handleError(_ error: K.ErrorHelper.Errors) {
        switch error {
            
        case .incorrectEmail,
                .unrecognizedEmail,
                .emailIsBadlyFormatted,
                .emailInUse:
            self.setErrorMessage(.email, message: error.message())
             
        case .incorrectPassword,
                .insufficientPassword:
            self.setErrorMessage(.password, message: error.message())
            
        case .passwordsDontMatch:
            self.setErrorMessage(.confirmPassword, message: error.message())
            
        case .failedToSaveUser,
                .troubleConnectingToFirebase,
                .firebaseTrouble:
            self.setErrorMessage(.firebase, message: error.message())

        }
    }
    
    private func setErrorMessage(_ type: K.ErrorHelper.ErrorType, message: String) {
        
        switch type {
        
        case .email:
            self.emailErrorMessage = message
            self.shouldShowEmailErrorMessage = true
            
        case .username:
            self.usernameErrorMessage = message
            self.shouldShowUserNameErrorMessage = true
            
        case .password:
            self.passwordErrorMessage = message
            self.shouldShowPasswordErrorMessage = true
            
        case .confirmPassword:
            self.confirmPasswordErrorMessage = message
            self.shouldShowConfirmPasswordError = true
            
        case .firebase:
            self.firebaseErrorMessage = message
            self.shouldShowFirebaseError = true
            
        }
    }
    private func checkForErrorAndSendAppropriateErrorMessage() {
        
        if usernameInput == "" {
            setErrorMessage(.username, message: "What can we call you?")
        } else {
            self.shouldShowUserNameErrorMessage = false
        }
        
        if emailInput == "" {
            setErrorMessage(.email, message: "Please provide an email address.")
        } else {
            self.shouldShowEmailErrorMessage = false
        }
        
        if passwordInput == "" {
            setErrorMessage(.password, message: "Please provide a password.")
        } else {
            self.shouldShowPasswordErrorMessage = false
        }
        
        if confirmPasswordInput != passwordInput {
            self.shouldShowConfirmPasswordError = true
        } else {
            self.shouldShowConfirmPasswordError = false
        }
    }
    
}


class LoginVM: ObservableObject {
    
    static let instance = LoginVM()
    
    @Published var emailInput = ""
    @Published var passwordInput = ""
    
    @Published var showingAlertPasswordReset = false
    
    //MARK: - Error Message Helpers
    @Published var shouldShowEmailErrorMessage = false
    @Published var shouldShowPasswordErrorMessage = false
    @Published var shouldShowFirebaseError = false

    @Published var emailErrorMessage = ""
    @Published var passwordErrorMessage = ""
    @Published var firebaseErrorMessage = ""
    
    @ObservedObject var network = NetworkManager()

    var auth = Authorization()


    func loginTapped() {
        
        guard isConnectedToNetwork() else {
            setErrorMessage(.firebase, message: "Please check your network connection and try again.")
            return
        }
        
        checkForErrorAndSendAppropriateErrorMessage()
        
        if fieldsAreFilled() {
            
            auth.signIn(email: emailInput,
                        password: passwordInput) { error in
                self.handleError(error)
            }
        }
    }
    
    private func fieldsAreFilled() -> Bool {
        emailInput != "" && passwordInput != ""
    }
    
    func forgotPasswordTapped() {
        
        auth.passwordReset(email: emailInput) { result in
            
            if result == true {
                
                self.showingAlertPasswordReset = true
            }
        } error: { error in
            
            if error == .firebaseTrouble {
                
                self.shouldShowFirebaseError = true
            }
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        network.connected
    }
    
    
    //MARK: - Errors
    
    private func handleError(_ error: K.ErrorHelper.Errors) {
        switch error {
            
        case .incorrectEmail,
                .unrecognizedEmail,
                .emailIsBadlyFormatted,
                .emailInUse:
            self.setErrorMessage(.email, message: error.message())
             
        case .incorrectPassword,
                .insufficientPassword:
            self.setErrorMessage(.password, message: error.message())
            
        case .passwordsDontMatch:
            self.setErrorMessage(.confirmPassword, message: error.message())
            
        case .failedToSaveUser,
                .troubleConnectingToFirebase,
                .firebaseTrouble:
            self.setErrorMessage(.firebase, message: error.message())

        }
    }
    
    private func setErrorMessage(_ type: K.ErrorHelper.ErrorType, message: String) {
        
        switch type {
        
        case .email:
            self.emailErrorMessage = message
            self.shouldShowEmailErrorMessage = true
            
        case .password:
            self.passwordErrorMessage = message
            self.shouldShowPasswordErrorMessage = true
            
        default:
            self.firebaseErrorMessage = message
            self.shouldShowFirebaseError = true
            
        }
    }
    
    private func checkForErrorAndSendAppropriateErrorMessage() {
        
        if emailInput == "" {
            setErrorMessage(.email, message: "Please provide an email address.")
        } else {
            self.shouldShowEmailErrorMessage = false
        }
        
        if passwordInput == "" {
            setErrorMessage(.password, message: "Please provide a password.")
        } else {
            self.shouldShowPasswordErrorMessage = false
        }
    }
    
}
