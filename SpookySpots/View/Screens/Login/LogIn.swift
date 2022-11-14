//
//  LogIn.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct LogIn: View {
    
    @State var emailInput = ""
    @State var passwordInput = ""
    
    @State var isSecured = true
    @Binding var index: Int
    
    @State var showingAlertPasswordRest = false
    
    var auth = Authorization()
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    //MARK: - Error Message Helpers
    @State var shouldShowEmailErrorMessage = false
    @State var shouldShowPasswordErrorMessage = false
    @State var shouldShowFirebaseError = false
    
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var firebaseErrorMessage = ""
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
        
    @EnvironmentObject var network: NetworkManager
    
    var body: some View {
        ZStack {
        ZStack(alignment: .bottom) {
            
            VStack {
                
                authTypeView
                emptySpace
                email
                password
                forgotPasswordButton
                emptySpace
            }
            .padding()
            .padding(.bottom, 65)
            .background(weenyWitch.light)
            .clipShape(CurvedShapeLeft())
            .contentShape(CurvedShapeLeft())
            .shadow(color: weenyWitch.orange.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeLoginTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            loginButton
        }
            
            
        .alert("Email Sent", isPresented: $showingAlertPasswordRest) {
            Button("OK", role: .cancel) { }
        }
            firebaseErrorBanner
    
        }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                loginTapped()
            default: break
            }
        }
    }
    
    private var firebaseErrorBanner: some View {

            NotificationBanner(color: weenyWitch.orange,
                               messageColor: weenyWitch.lightest,
                               message: $firebaseErrorMessage,
                               isVisible: $shouldShowFirebaseError)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.shouldShowFirebaseError = false
                }
            }
    }
    
    private var authTypeView: some View {
        HStack {
            VStack(spacing: 50) {
                Text("Login")
                    .foregroundColor(self.index == 0 ? weenyWitch.brown : weenyWitch.lightest)
                    .font(.title)
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 0 ? weenyWitch.brown : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }
    
    private var email: some View {
        UserInputCellWithIcon(
            input: $emailInput,
            shouldShowErrorMessage: $shouldShowEmailErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "envelope.fill"),
            placeholderText: "Email Address",
            errorMessage: emailErrorMessage)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }
    
    private var password: some View {
        UserInputCellWithIcon(
            input: $passwordInput,
            shouldShowErrorMessage: $shouldShowPasswordErrorMessage,
            isSecured: $isSecured,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: isSecured ? "eye.slash.fill" : "eye"),
            placeholderText: "Password",
            errorMessage: passwordErrorMessage)
        .focused($focusedField, equals: .password)
        .submitLabel(.done)
    }

    
    private var emptySpace: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 100, height: 36.25)
    }
    
    //MARK: - Buttons
    
    private var forgotPasswordButton: some View {
        HStack {
            Spacer(minLength: 0)
            
            Button(action: forgotPasswordTapped) {
                Text("Forgot Password?")
                    .foregroundColor(weenyWitch.lightest)
            }
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var loginButton: some View {
        Button(action: loginTapped) {
            Text("LOGIN")
                .foregroundColor(weenyWitch.brown)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(weenyWitch.orange)
                .clipShape(Capsule())
                .shadow(color: weenyWitch.lightest.opacity(0.1),
                        radius: 5, x: 0, y: 5)
        }
        .offset(y: 25)
        .opacity(self.index == 0 ? 1 : 0)
    }
    
    
    //MARK: - Methods
    
    private func authTypeLoginTapped() {
        self.index = 0
    }
    
    private func forgotPasswordTapped() {
        
        auth.passwordReset(email: emailInput) { result in
            
            if result == true {
                
                self.showingAlertPasswordRest = true
            }
        } error: { error in
            
            if error == .firebaseTrouble {
                
                self.shouldShowFirebaseError = true
            }
        }
    }
    
    func setErrorMessage(_ type: ErrorMessageType, message: String) {
        
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
    
    func isConnectedToNetwork() -> Bool {
        network.connected
    }
    
    private func loginTapped() {
        
        print(isConnectedToNetwork())
        
        guard isConnectedToNetwork() else {
            setErrorMessage(.firebase, message: "Please check your network connection and try again.")
            return
        }
        
        checkForErrorAndSendAppropriateErrorMessage()
        
        if fieldsAreFilled() {
            
            auth.signIn(email: emailInput, password: passwordInput) { error in
                switch error {
                    
                case .incorrectEmail,
                        .unrecognizedEmail,
                        .emailIsBadlyFormatted,
                        .emailInUse:
                    setErrorMessage(.email, message: error.message())
                     
                case .incorrectPassword,
                        .insufficientPassword:
                    setErrorMessage(.password, message: error.message())
                    
                case .failedToSaveUser,
                        .troubleConnectingToFirebase,
                        .firebaseTrouble:
                    setErrorMessage(.firebase, message: error.message())
                    
                default:
                    setErrorMessage(.firebase, message: error.message())
                }
            }
        }
    }
    
    private func showPasswordTapped() {
        self.isSecured.toggle()
    }
    
    private func fieldsAreFilled() -> Bool {
        emailInput != "" && passwordInput != ""
    }
    
    private func checkForErrorAndSendAppropriateErrorMessage() {
        
        if emailInput == "" {
            self.shouldShowEmailErrorMessage = true
        } else {
            self.shouldShowEmailErrorMessage = false
        }
        
        if passwordInput == "" {
            self.shouldShowPasswordErrorMessage = true
        } else {
            self.shouldShowPasswordErrorMessage = false
        }
    }

    //MARK: - Field
    enum Field {
        case email, password
    }
}

//MARK: - Previews
struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn(index: .constant(0))
            .environmentObject(NetworkManager())
    }
}

//MARK: - Shape Helper
struct CurvedShapeLeft : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: 120))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

//MARK: - Error Message Type
enum ErrorMessageType {
    case email, password, confirmPassword, firebase
}
