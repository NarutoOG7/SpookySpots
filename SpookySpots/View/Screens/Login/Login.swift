////
////  Login.swift
////  SpookySpots
////
////  Created by Spencer Belton on 3/24/22.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct LeftPointShape : Shape {
//    
//    func path(in rect: CGRect) -> Path {
//        
//        return Path { path in
//            path.move(to: CGPoint(x: 0, y: 100))
//            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//            path.addLine(to: CGPoint(x: 0, y: rect.height))
//            path.addLine(to: CGPoint(x: 0, y: 0))
//        }
//    }
//}
//
//
//
//struct Login: View {
//    @AppStorage("isLoggedIn") private var isLoggedIn = false
//    @State private var selection = 0
//    @ObservedObject var userStore = UserStore.instance
//    var authorization = Authorization.instance
//    var body: some View {
//        if userStore.isSignedIn {
//            // Home
//            TabBarSetup()
//        } else {
//            //Sign In View
//            AuthView(authType: .signIn)
//        }
//    }
//    
//    var logo: some View {
//        Text("Logo")
//            .background(RoundedRectangle(cornerRadius: 20).frame(width: 60, height: 60))
//    }
//}
//
//struct LoginSignUpView: View {
//    
//    enum AuthType: String {
//        case signIn = "Sign In"
//        case createAccount = "Create Account"
//    }
//    
//    var authorization = Authorization.instance
//    
//    @State var authType = AuthType.signIn
//    @State var userName = ""
//    @State var email = ""
//    @State var password = ""
//    @State var confirmPassword = ""
//    
//    @ObservedObject var userstore = UserStore.instance
//    
//    var body: some View {
//        
//        if isSigningIn() {
//            logInView
//        } else {
//            signUpView
//        }
//            
//    }
//    
//    var logo: some View {
//        Text("Logo")
//            .background(RoundedRectangle(cornerRadius: 20).frame(width: 60, height: 60))
//    }
//    
//    var logInView: some View {
//        VStack {
//            
//            logo
//            
//            VStack {
//                
//                HStack {
//                    Text("Login")
//                        .font(.title)
//                        .fontWeight(.bold)
//                    Spacer(minLength: 0)
//                }.padding(.top, 40)
//            
//            emailAddressForm
//            passwordField
//            } .padding()
//        }.preferredColorScheme(.dark)
//    }
//    
//    var signUpView: some View {
//        VStack {
//            userNameField
//        }
//    }
//    
//    //MARK: - SubViews
//    private var userNameField: some View {
//        TextField("Name", text: $userName)
//            .disableAutocorrection(true)
//            .hidden(isSigningIn())
//    }
//    
//    private var emailAddressForm: some View {
//        TextField("Email Address", text: $email)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    private var passwordField: some View {
//        SecureField("Password", text: $password)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    private var confirmPasswordField: some View {
//        SecureField("Password", text: $confirmPassword)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    //MARK: - Buttons
//    private var loginButton: some View {
//        Button(action: loginTapped) {
//            Text("Log In")
//        }
//    }
//    
//    private var signupButton: some View {
//        Button(action: signupTapped) {
//            Text("Sign Up")
//        }
//    }
//    
//    private var confirmButton: some View {
//        Button(action: confirmPressed) {
//            Text(authType.rawValue)
//        }
//    }
//    
//    //MARK: - Mehtods
//    private func loginTapped() {
//        authType = .signIn
//    }
//    
//    private func signupTapped() {
//        authType = .createAccount
//    }
//    
//    private func confirmPressed() {
//        if authType == .signIn {
//            authorization.signIn(email: email, password: password)
//        } else {
//            authorization.signUp(userName: userName, email: email, password: password, confirmPassword: confirmPassword)
//        }
//    }
//    
//    private func isSigningIn() -> Bool {
//        authType == .signIn
//    }
//}
//
//
//struct AuthView: View {
//    
//    enum AuthType: String {
//        case signIn = "Sign In"
//        case createAccount = "Create Account"
//    }
//    @State var userName = ""
//    @State var email = ""
//    @State var password = ""
//    @State var confirmPassword = ""
//    @ObservedObject var userstore = UserStore.instance
//    var authorization = Authorization.instance
//    //    @StateObject var loginData = LoginViewModel()
//    
//    var authType: AuthType
//    
//    var body: some View {
//        NavigationView {
//        VStack {
//            VStack(spacing: 15) {
//                userNameField
//                emailAddressForm
//                passwordField
//                confirmPasswordField
//            }
//            submitButton
//            goToCreateAccountButton
////            NavigationLink("Create Account", destination: AuthView(authType: .createAccount))
////                .padding()
//        }
//        }
//        .padding()
//        .navigationTitle(authType.rawValue)
//    }
//    
//    //MARK: - SubViews
//    private var userNameField: some View {
//        TextField("Name", text: $userName)
//            .disableAutocorrection(true)
//            .hidden(isSigningIn())
//    }
//    
//    private var emailAddressForm: some View {
//        TextField("Email Address", text: $email)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    private var passwordField: some View {
//        SecureField("Password", text: $password)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    private var confirmPasswordField: some View {
//        SecureField("Password", text: $confirmPassword)
//            .disableAutocorrection(true)
//            .autocapitalization(.none)
//    }
//    
//    //MARK: - Buttons
//    private var submitButton: some View {
//        Button(action: submitSignInOrSignUp) {
//            Text(authType.rawValue)
//                .foregroundColor(.white)
//                .frame(width: 200, height: 50)
//                .background(Color.blue)
//                .cornerRadius(8)
//        }
//    }
//    
//    private var goToCreateAccountButton: some View {
//        NavigationLink(isSigningIn() ? "Create Account" : "", destination: AuthView(authType: .createAccount))
//            .padding()
//    }
//    
//    
//    //MARK: - Methods
//    private func submitSignInOrSignUp() {
//        if authType == .signIn {
//            authorization.signIn(email: email, password: password)
//        } else {
//            authorization.signUp(userName: userName, email: email, password: password, confirmPassword: confirmPassword)
//        }
//    }
//    
//    private func isSigningIn() -> Bool {
//        authType == .signIn
//    }
//}
//
//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginSignUpView()
//    }
//}
//
//extension View {
//    func hidden(_ shouldHide: Bool) -> some View  {
//        opacity(shouldHide ? 0 : 1)
//    }
//}
