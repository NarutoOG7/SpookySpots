//
//  Login.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct Login: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var selection = 0
    @ObservedObject var authorization = Authorization.instance
    var body: some View {
        if authorization.signedIn {
            // Home
            TabBarSetup()
        } else {
            //Sign In View
            AuthView(authType: .signIn)
        }
    }
}

class Authorization: ObservableObject {
    static let instance = Authorization()
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing in: \(error)")
            } else {
                guard result != nil else {
                    print("no results")
                    return
                }
                DispatchQueue.main.async {
                    self.signedIn = true
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
                DispatchQueue.main.async {
                    self.signedIn = true
                }
                let user = User(id: result.user.uid, name: userName, email: result.user.email ?? "")
                self.db.collection("Users").document(user.id).setData([
                    "UID" : user.id,
                    "name" : userName
                ]) { error in
                    if let error = error {
                        print(error)
                    } else {
                        print("document fetched successfully")
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.signedIn = false
        } catch {
            print("Trouble siging out. \(error)")
            // handle error
        }
    }
}

struct AuthView: View {
    
    enum AuthType: String {
        case signIn = "Sign In"
        case createAccount = "Create Account"
    }
    @State var userName = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @ObservedObject var authorization = Authorization.instance
    //    @StateObject var loginData = LoginViewModel()
    
    var authType: AuthType
    
    var body: some View {
        NavigationView {
        VStack {
            VStack(spacing: 15) {
                userNameField
                emailAddressForm
                passwordField
            }
            submitButton
            goToCreateAccountButton
//            NavigationLink("Create Account", destination: AuthView(authType: .createAccount))
//                .padding()
        }
        }
        .padding()
        .navigationTitle(authType.rawValue)
    }
    
    //MARK: - SubViews
    private var userNameField: some View {
        TextField("Name", text: $userName)
            .disableAutocorrection(true)
            .hidden(isSigningIn())
    }
    
    private var emailAddressForm: some View {
        TextField("Email Address", text: $email)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    
    //MARK: - Buttons
    private var submitButton: some View {
        Button(action: submitSignInOrSignUp) {
            Text(authType.rawValue)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
    
    private var goToCreateAccountButton: some View {
        NavigationLink(isSigningIn() ? "Create Account" : "", destination: AuthView(authType: .createAccount))
            .padding()
    }
    
    
    //MARK: - Methods
    private func submitSignInOrSignUp() {
        if authType == .signIn {
            authorization.signIn(email: email, password: password)
        } else {
            authorization.signUp(userName: userName, email: email, password: password, confirmPassword: confirmPassword)
        }
    }
    
    private func isSigningIn() -> Bool {
        authType == .signIn
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View  {
        opacity(shouldHide ? 0 : 1)
    }
}
