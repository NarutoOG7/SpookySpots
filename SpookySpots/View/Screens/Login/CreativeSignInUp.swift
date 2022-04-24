//
//  CreativeSignInUp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/14/22.
//

import SwiftUI
import AuthenticationServices


struct CreativeSignInUp: View {
    @State var index = 0
    
    @State var firebaseError = false
    
    @State var showingAlertForFirebaseError = false
    
    @ObservedObject var userStore = UserStore.instance
    
    var body: some View {
        
        GeometryReader { _ in
            VStack {
                Spacer()
                
                VStack {
                    VStack(spacing: -20) {
                        logo
                        
                        ZStack {
                            SignUP(index: self.$index)
                                .zIndex(Double(self.index))
                            Login(index: self.$index)
                        }
                    }
                    HStack(spacing: 15) {
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                        Text("OR")
                            .foregroundColor(Color.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 25)
                    
                    
                    //                HStack(spacing: 25) {
                    //
                    //                    appleButton
                    //                    facebookButton
                    //                    twitterButton
                    //
                    //                }
                    .padding(.top, 30)
                    //                Spacer()
                    guest
                }
                .padding(.vertical)
                
                Spacer()
            }
            .alert("Firebase Error", isPresented: $showingAlertForFirebaseError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("There was an error with firebase. Check your connection and try again.")
            }

        }
        .preferredColorScheme(.dark)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
    
    var logo: some View {
        Image("apple")
            .logoStyle()
        
    }
    
    //MARK: - Other Options
    private var appleButton: some View {
        //        Button(action: appleTapped) {
        //            Image("apple")
        //                .logoStyle()
        //        }
        //
        //
        SignInWithAppleButton(
            onRequest: { request in
                AppleSignIn().signIn(request)
            },
            onCompletion: { result in
                AppleSignIn().completion(result: result)
            }
        ).frame(width: 50, height: 50)
        
    }
    
    private var facebookButton: some View {
        Button(action: facebookTapped) {
            Image("apple")
                .logoStyle()
        }
    }
    
    private var twitterButton: some View {
        Button(action: twitterTapped) {
            Image("apple")
                .logoStyle()
        }
    }
    
    private var guest: some View {
        Text("Continue As Guest")
            .font(.title3)
            .fontWeight(.light)
            .italic()
            .foregroundColor(.pink)
            .onTapGesture(perform: continueAsGuestTapped)
            .padding()
    }
    
    private func facebookTapped() {
        
    }
    
    private func twitterTapped() {
        
    }
    
    private func continueAsGuestTapped() {
        Authorization.instance.anonymousSignIn { error in
            if error == .troubleConnectingToFirebase {
                firebaseError = true
            }
            
            DispatchQueue.main.async {
                userStore.isGuest = true
            }
        }

    }
}

struct CreativeSignInUp_Previews: PreviewProvider {
    static var previews: some View {
        CreativeSignInUp()
    }
}

//MARK: - Login
struct Login: View {
    
    @State var emailInput = ""
    @State var passwordInput = ""
    @Binding var index: Int
    
    @State var emailOrPasswordInvalid = false
    @State var firebaseError = false
    
    @State var showingAlertPasswordRest = false
    
    var auth = Authorization()
    var body: some View {
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
            .background(Color.black)
            .clipShape(CurvedShapeLeft())
            .contentShape(CurvedShapeLeft())
            .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeLoginTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            loginButton
        }
        .alert("Email Sent", isPresented: $showingAlertPasswordRest) {
            Button("OK", role: .cancel) { }
        }

    }
    
    private var authTypeView: some View {
        HStack {
            VStack(spacing: 50) {
                Text("Login")
                    .foregroundColor(self.index == 0 ? .white : .gray)
                    .font(.title)
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 0 ? Color.pink : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }
    
    private var email: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.white)
                
                TextField("Email Address", text: self.$emailInput)
                    .foregroundColor(.white)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            
            Divider().background(Color.gray)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var password: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.white)
                
                SecureField("Password", text: self.$passwordInput)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            Divider().background(Color.gray)
            
            passwordError
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var emptySpace: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 100, height: 36.25)
        //            .padding(.top, 40)
    }
    
    //MARK: - ErrorMessages
    private var passwordError: some View {
        let view: Text
        if emailOrPasswordInvalid {
            view = Text(AuthErrorTypes.incorrectEmailOrPassword.rawValue)
        } else {
            view = Text("")
        }
        return view
            .foregroundColor(.red)
    }
    
    //MARK: - Buttons
    private var forgotPasswordButton: some View {
        HStack {
            Spacer(minLength: 0)
            
            Button(action: forgotPasswordTapped) {
                Text("Forgot Password?")
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var loginButton: some View {
        Button(action: loginTapped) {
            Text("LOGIN")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(Color.pink)
                .clipShape(Capsule())
                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
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
                firebaseError = true
            }
        }
    }
    
    private func loginTapped() {
        auth.signIn(email: emailInput, password: passwordInput) { error in
            switch error {
            case .incorrectEmailOrPassword:
                self.emailOrPasswordInvalid = true
            case .firebaseTrouble:
                self.firebaseError = true
            default: break
            }
        }
    }
}

//MARK: - SignUp
struct SignUP: View {
    
    @State var usernameInput = ""
    @State var emailInput = ""
    @State var passwordInput = ""
    @State var confirmPasswordInput = ""
    
    @State var passwordsMatch = true
    @State var firebaseError = false
    @State var emailInUseAlready = false
    @State var failedToSaveUser = false
    
    @Binding var index: Int
    var auth = Authorization()
    
    var body: some View {
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
            .background(Color.black)
            .clipShape(CurvedShapeRight())
            .contentShape(CurvedShapeRight())
            .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeSignUpTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            signUpButton
        }
    }
    private var authTypeView: some View {
        HStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 50) {
                Text("Sign Up")
                    .foregroundColor(self.index == 1 ? .white : .gray)
                    .font(.title)
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 1 ? Color.blue : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
        }
        .padding(.top, 30)
    }
    
    private var userNameField: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                
                TextField("Your Name", text: self.$usernameInput)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            
            Divider().background(Color.gray)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var email: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.white)
                
                TextField("Email Address", text: self.$emailInput)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            
            Divider().background(Color.gray)
            emailInUseErrorView
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var password: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.white)
                
                SecureField("Password", text: self.$passwordInput)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            Divider().background(Color.gray)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var confirmPassword: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.white)
                
                SecureField("Confirm Password", text: self.$confirmPasswordInput)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
            Divider().background(Color.gray)
            
            passwordErrorView
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    //MARK: - Error Views
    private var emailInUseErrorView: some View {
        let view: Text
        if emailInUseAlready {
            view = Text(AuthErrorTypes.emailInUse.rawValue)
        } else {
            view = Text("")
        }
        return view
            .foregroundColor(.red)
    }
    
    private var passwordErrorView: some View {
        let view: Text
        if passwordsMatch {
            view = Text("")
        } else {
            view = Text(AuthErrorTypes.passwordsDontMatch.rawValue)
        }
        return view
            .foregroundColor(.red)
    }
    
    //MARK: - Buttons
    
    private var signUpButton: some View {
        Button(action: signUpTapped) {
            Text("SIGNUP")
                .foregroundColor(self.index == 1 ? .white : .gray)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(self.index == 1 ? Color.blue : Color.clear)
                .clipShape(Capsule())
                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
        }
        .offset(y: 25)
        .opacity(self.index == 1 ? 1 : 0)
    }
    
    //MARK: - Methods
    
    private func signUpTapped() {
        auth.signUp(userName: usernameInput, email: emailInput, password: passwordInput, confirmPassword: confirmPasswordInput) { error in
            switch error {
            case .passwordsDontMatch:
                self.passwordsMatch = false
            case .firebaseTrouble:
                self.firebaseError = true
            case .emailInUse:
                self.emailInUseAlready = true
            case .failedToSaveUser:
                self.failedToSaveUser = true
            case .troubleConnectingToFirebase:
                self.firebaseError = true
            default: break
            }
        }
        
    }
    
    private func authTypeSignUpTapped() {
        self.index = 1
    }
    
    private func signUpSuccess() {
        
    }
    
    private func signUpError() {
        
    }
}

//MARK: - Helpers
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

extension Image {
    func logoStyle() -> some View {
        return self
            .resizable()
            .renderingMode(.original)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
}
