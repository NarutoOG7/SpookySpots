//
//  SignUp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct SignUp: View {
    
    @State var usernameInput = ""
    @State var emailInput = ""
    @State var passwordInput = ""
    @State var confirmPasswordInput = ""
     
    @State var passwordIsSecured = true
    @State var confirmPasswordIsSecured = true
    
    let weenyWitch = K.Colors.WeenyWitch.self
    @Binding var index: Int
    var auth = Authorization()
    
    //MARK: - TextField Focus State
    @FocusState private var focusedField: Field?
    
    //MARK: - ErrorMessage Helpers
    @State var shouldShowUserNameErrorMessage = false
    @State var shouldShowEmailErrorMessage = false
    @State var shouldShowPasswordErrorMessage = false
    @State var shouldShowConfirmPasswordError = false
    @State var shouldShowFirebaseError = false

    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var confirmPasswordErrorMessage = ""
    @State var firebaseErrorMessage = ""
    
    
    @EnvironmentObject var network: Network
    
    var body: some View {
        ZStack {
        ZStack(alignment: .bottom) {
            
            VStack {
                authTypeView
                userNameField
                email
                password
                confirmPassword
            }
            .padding()
            .padding(.bottom, 65)
            .background(K.Colors.WeenyWitch.light)
            .clipShape(CurvedShapeRight())
            .contentShape(CurvedShapeRight())
            .shadow(color: K.Colors.WeenyWitch.orange.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeSignUpTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            signUpButton
        }
            firebaseErrorBanner
        }
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                signUpTapped()
            default: break
            }
        }
    }
    private var authTypeView: some View {
        HStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 50) {
                Text("Sign Up")
                    .foregroundColor(self.index == 1 ? K.Colors.WeenyWitch.brown : K.Colors.WeenyWitch.lightest)
                    .font(.title)
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 1 ? K.Colors.WeenyWitch.brown : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
        }
        .padding(.top, 30)
    }
    
    private var userNameField: some View {
        UserInputCellWithIcon(
            input: $usernameInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "person.fill"),
            placeholderText: "Your Name",
            errorMessage: "Please provide a name.",
            shouldShowErrorMessage: $shouldShowUserNameErrorMessage,
            isSecured: .constant(false))
        .focused($focusedField, equals: .username)
        .submitLabel(.next)
    }
    

    
    private var email: some View {
        UserInputCellWithIcon(
            input: $emailInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "envelope.fill"),
            placeholderText: "Email Address",
            errorMessage: emailErrorMessage,
            shouldShowErrorMessage: $shouldShowEmailErrorMessage,
            isSecured: .constant(false))
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }

    private var password: some View {
        UserInputCellWithIcon(
            input: $passwordInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: passwordIsSecured ? "eye.slash.fill" : "eye" ),
            placeholderText: "Password",
            errorMessage: passwordErrorMessage,
            shouldShowErrorMessage: $shouldShowPasswordErrorMessage,
            isSecured: $passwordIsSecured,
            canSecure: true)
        .focused($focusedField, equals: .password)
        .submitLabel(.next)
    }
    
    private var confirmPassword: some View {
        UserInputCellWithIcon(
            input: $confirmPasswordInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: confirmPasswordIsSecured ? "eye.slash.fill" : "eye" ),
            placeholderText: "Confirm Password",
            errorMessage: PasswordErrorType.dontMatch.rawValue,
            shouldShowErrorMessage: $shouldShowConfirmPasswordError,
            isSecured: $confirmPasswordIsSecured,
            canSecure: true)
        .focused($focusedField, equals: .confirmPassword)
        .submitLabel(.done)
    }
    
    //MARK: - Buttons
    
    private var signUpButton: some View {
        Button(action: signUpTapped) {
            Text("SIGNUP")
                .foregroundColor(self.index == 1 ? K.Colors.WeenyWitch.brown : .gray)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(self.index == 1 ? K.Colors.WeenyWitch.orange : Color.clear)
                .clipShape(Capsule())
                .shadow(color: K.Colors.WeenyWitch.lightest.opacity(0.1), radius: 5, x: 0, y: 5)
        }
        .offset(y: 25)
        .opacity(self.index == 1 ? 1 : 0)
    }
    
    private var firebaseErrorBanner: some View {

            NotificationBanner(color: weenyWitch.orange, messageColor: weenyWitch.lightest, message: $firebaseErrorMessage, isVisible: $shouldShowFirebaseError)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.shouldShowFirebaseError = false
                }
            }
    }
    
    //MARK: - Methods
    
    private func signUpTapped() {
        
        guard isConnectedToNetwork() else {
            setErrorMessage(.firebase, message: "Please check your network connection and try again.")
            return
        }
        
        checkForErrorAndSendAppropriateErrorMessage()
        
        if fieldsAreFilled() {
            
            auth.signUp(userName: usernameInput, email: emailInput, password: passwordInput, confirmPassword: confirmPasswordInput) { error in
                
                switch error {
                    
                case .incorrectEmail,
                        .unrecognizedEmail,
                        .emailIsBadlyFormatted,
                        .emailInUse:
                    setErrorMessage(.email, message: error.message())
                     
                case .incorrectPassword,
                        .insufficientPassword:
                    setErrorMessage(.password, message: error.message())
                    
                case .passwordsDontMatch:
                    setErrorMessage(.confirmPassword, message: error.message())
                    
                case .failedToSaveUser,
                        .troubleConnectingToFirebase,
                        .firebaseTrouble:
                    setErrorMessage(.firebase, message: error.message())

                }
            }
        }
        
        
    }
    
    private func checkForErrorAndSendAppropriateErrorMessage() {
        if usernameInput == "" {
            self.shouldShowUserNameErrorMessage = true
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
    
    private func fieldsAreFilled() -> Bool {
        usernameInput != "" &&
        emailInput != "" &&
        passwordInput != "" &&
        confirmPasswordInput != ""
    }
    
    
    
    private func authTypeSignUpTapped() {
        self.index = 1
    }
    
    func isConnectedToNetwork() -> Bool {
        self.network.connected
    }
    
    private func setErrorMessage(_ type: ErrorMessageType, message: String) {
        switch type {
        
        case .email:
            self.emailErrorMessage = message
            self.shouldShowEmailErrorMessage = true
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
    
    //MARK: - Field
    enum Field {
        case username, email, password, confirmPassword
    }
}


//MARK: - Previews
struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp(index: .constant(0))
            .environmentObject(Network())
    }
}

//MARK: - Shape Helper
struct CurvedShapeRight : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 120))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}

//MARK: - Password Error Type
enum PasswordErrorType: String {
    case empty = "Please provide a password."
    case tooWeak = "Password must be at least 6 characters long."
    case dontMatch = "Passwords must match."
}
