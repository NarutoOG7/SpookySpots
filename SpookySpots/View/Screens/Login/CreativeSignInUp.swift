//
//  CreativeSignInUp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/14/22.
//

import SwiftUI


struct CreativeSignInUp: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
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
            .background(Color.pink)
            .clipShape(CurvedShapeLeft())
            .contentShape(CurvedShapeLeft())
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeLoginTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            loginButton
        }
    }
    
    private var authTypeView: some View {
        HStack {
            VStack(spacing: 10) {
            Text("Login")
                .foregroundColor(self.index == 0 ? .white : .gray)
                .font(.title)
                .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 0 ? Color.blue : Color.clear)
                    .frame(width: 90, height: 4)
                
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
            }
            
            Divider().background(Color.black)
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
            }
            Divider().background(Color.black)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var emptySpace: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 100, height: 30)
//            .padding(.top, 40)
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
                .background(Color.blue)
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
        
    }
    
    private func loginTapped() {
        
    }
}


//MARK: - SignUp
struct SignUP: View {
    
    @State var usernameInput = ""
    @State var emailInput = ""
    @State var passwordInput = ""
    @State var confirmPasswordInput = ""
    @Binding var index: Int
    
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
            .background(Color.pink)
            .clipShape(CurvedShapeRight())
            .contentShape(CurvedShapeRight())
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeSignUpTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            
            confirmSignUpButton
        }
    }
    private var authTypeView: some View {
        HStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 10) {
                Text("Sign Up")
                    .foregroundColor(self.index == 1 ? .white : .gray)
                    .font(.title)
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 1 ? Color.blue : Color.clear)
                    .frame(width: 90, height: 4)
                
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
            }
            
            Divider().background(Color.black)
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
            }
            
            Divider().background(Color.black)
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
            }
            Divider().background(Color.black)
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
            }
            Divider().background(Color.black)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    //MARK: - Buttons
    
    private var confirmSignUpButton: some View {
        Button(action: confirmSignUpTapped) {
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
    
    private func confirmSignUpTapped() {
        
    }
    
    private func authTypeSignUpTapped() {
        self.index = 1
    }
}


//MARK: - Home
struct Home: View {
    
    @State var index = 0
    
    var body: some View {
        
        GeometryReader { _ in
            VStack {
                logo
                
                ZStack {
                    SignUP(index: self.$index)
                        .zIndex(Double(self.index))
                    Login(index: self.$index)
                }
                
                HStack(spacing: 15) {
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                    
                    Text("OR")
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
            
                HStack(spacing: 25) {
                    
                    appleButton
                    facebookButton
                    twitterButton
                    
                }
            }
        }
        .background(Color.purple.edgesIgnoringSafeArea(.all))
    }
    
    var logo: some View {
        LogoImage(image: Image("apple"))
    }
    
    //MARK: - Other Options
    private var appleButton: some View {
        LogoImage(image: Image("apple"))
    }
    
    private var facebookButton: some View {
        LogoImage(image: Image("apple"))
    }
    
    private var twitterButton: some View {
        LogoImage(image: Image("apple"))
    }
}

struct LogoImage: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .renderingMode(.original)
            .frame(width: 50, height: 50)
            .clipShape(Circle()) as! Image
    }
}

struct CurvedShapeLeft : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: 100))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}


struct CurvedShapeRight : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 100))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}
