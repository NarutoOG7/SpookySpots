//
//  SignUp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct SignUp: View {
     
    @State var passwordIsSecured = true
    @State var confirmPasswordIsSecured = true
    
    @Binding var index: Int
    
    var auth = Authorization()
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    //MARK: - TextField Focus State
    @FocusState private var focusedField: Field?
    
    @ObservedObject var signupVM = SignupVM.instance
    
    @EnvironmentObject var network: NetworkManager
    
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
                signupVM.signupTapped()
            default: break
            }
        }
    }
    private var authTypeView: some View {
        HStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 50) {
                Text("Sign Up")
                    .foregroundColor(self.index == 1 ?
                                     weenyWitch.brown : weenyWitch.lightest)
                    .font(.avenirNext(size: 27))
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 1 ?
                          weenyWitch.brown : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
        }
        .padding(.top, 30)
    }
    
    private var userNameField: some View {
        UserInputCellWithIcon(
            input: $signupVM.usernameInput,
            shouldShowErrorMessage: $signupVM.shouldShowUserNameErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "person.fill"),
            placeholderText: "Your Name",
            errorMessage: "Please provide a name.")
        .focused($focusedField, equals: .username)
        .submitLabel(.next)
    }
    

    
    private var email: some View {
        UserInputCellWithIcon(
            input: $signupVM.emailInput,
            shouldShowErrorMessage: $signupVM.shouldShowEmailErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "envelope.fill"),
            placeholderText: "Email Address",
            errorMessage: signupVM.emailErrorMessage)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }

    private var password: some View {
        UserInputCellWithIcon(
            input: $signupVM.passwordInput,
            shouldShowErrorMessage: $signupVM.shouldShowPasswordErrorMessage,
            isSecured: $passwordIsSecured,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: passwordIsSecured ? "eye.slash.fill" : "eye" ),
            placeholderText: "Password",
            errorMessage: signupVM.passwordErrorMessage,
            canSecure: true)
        .focused($focusedField, equals: .password)
        .submitLabel(.next)
    }
    
    private var confirmPassword: some View {
        UserInputCellWithIcon(
            input: $signupVM.confirmPasswordInput,
            shouldShowErrorMessage: $signupVM.shouldShowConfirmPasswordError,
            isSecured: $confirmPasswordIsSecured,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: confirmPasswordIsSecured ? "eye.slash.fill" : "eye" ),
            placeholderText: "Confirm Password",
            errorMessage: K.ErrorHelper.Messages.Auth.passwordsDontMatch.rawValue,
            canSecure: true)
        .focused($focusedField, equals: .confirmPassword)
        .submitLabel(.done)
    }
    
    //MARK: - Buttons
    
    private var signUpButton: some View {
        Button(action: signupVM.signupTapped) {
            Text("SIGNUP")
                .foregroundColor(weenyWitch.brown)
                .font(.avenirNext(size: 20))
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(weenyWitch.orange)
                .clipShape(Capsule())
                .shadow(color: weenyWitch.lightest.opacity(0.1),
                        radius: 5, x: 0, y: 5)
        }
        .offset(y: 25)
        .opacity(self.index == 1 ? 1 : 0)
    }
    
    private var firebaseErrorBanner: some View {

            NotificationBanner(message: $signupVM.firebaseErrorMessage,
                               isVisible: $signupVM.shouldShowFirebaseError)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    signupVM.shouldShowFirebaseError = false
                }
            }
    }
    
    //MARK: - Methods
    
    private func authTypeSignUpTapped() {
        self.index = 1
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
            .environmentObject(NetworkManager())
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
