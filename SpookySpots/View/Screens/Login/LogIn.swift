//
//  LogIn.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct LogIn: View {
    
    @State var isSecured = true
    
    @Binding var index: Int
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @FocusState private var focusedField: Field?
    
    @ObservedObject var loginVM = LoginVM.instance
            
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
            
            
        .alert("Email Sent", isPresented: $loginVM.showingAlertPasswordReset) {
            Button("OK", role: .cancel) { }
        }
            firebaseErrorBanner
    
        }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                loginVM.loginTapped()
            default: break
            }
        }
    }
    
    private var firebaseErrorBanner: some View {

            NotificationBanner(message: $loginVM.firebaseErrorMessage,
                               isVisible: $loginVM.shouldShowFirebaseError)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    loginVM.shouldShowFirebaseError = false
                }
            }
    }
    
    private var authTypeView: some View {
        HStack {
            VStack(spacing: 50) {
                Text("Login")
                    .foregroundColor(self.index == 0 ?
                                     weenyWitch.brown : weenyWitch.lightest)
                    .font(.avenirNext(size: 27))
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 0 ?
                          weenyWitch.brown : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }
    
    private var email: some View {
        UserInputCellWithIcon(
            input: $loginVM.emailInput,
            shouldShowErrorMessage: $loginVM.shouldShowEmailErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: "envelope.fill"),
            placeholderText: "Email Address",
            errorMessage: loginVM.emailErrorMessage)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }
    
    
    private var password: some View {
        UserInputCellWithIcon(
            input: $loginVM.passwordInput,
            shouldShowErrorMessage: $loginVM.shouldShowPasswordErrorMessage,
            isSecured: $isSecured,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: Image(systemName: isSecured ? "eye.slash.fill" : "eye"),
            placeholderText: "Password",
            errorMessage: loginVM.passwordErrorMessage,
            canSecure: true)
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
            
            Button(action: loginVM.forgotPasswordTapped) {
                Text("Forgot Password?")
                    .font(.avenirNext(size: 18))
                    .foregroundColor(weenyWitch.lightest)
            }
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var loginButton: some View {
        Button(action: loginVM.loginTapped) {
            Text("LOGIN")
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
        .opacity(self.index == 0 ? 1 : 0)
    }
    
    
    //MARK: - Methods
    
    private func authTypeLoginTapped() {
        self.index = 0
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
