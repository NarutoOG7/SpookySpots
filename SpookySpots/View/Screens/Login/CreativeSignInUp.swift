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
                            SignUp(index: self.$index)
                                .zIndex(Double(self.index))
                            LogIn(index: self.$index)
                        }
                    }
                    HStack(spacing: 15) {
                        
                        Rectangle()
                            .fill(K.Colors.WeenyWitch.light)
                            .frame(height: 1)
                        
                        Text("OR")
                            .foregroundColor(K.Colors.WeenyWitch.lightest)
                        
                        Rectangle()
                            .fill(K.Colors.WeenyWitch.light)
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
        .background(K.Colors.WeenyWitch.black.edgesIgnoringSafeArea(.all))
    }
    
    var logo: some View {
        Image("SimpleLogo")
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 50)
        
    }
    
    //MARK: - Other Options
    
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
            .foregroundColor(K.Colors.WeenyWitch.orange)
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

//MARK: - Previews
struct CreativeSignInUp_Previews: PreviewProvider {
    static var previews: some View {
        CreativeSignInUp()
    }
}


//MARK: - Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
