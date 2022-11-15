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
    
    @State var firebaseErrorMessage = ""
    
    @State var showingAlertForFirebaseError = false
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @ObservedObject var userStore = UserStore.instance

    
    var body: some View {
        
        GeometryReader { _ in
            ZStack {
                
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
                        
                        orDivider
                        
                        .padding(.top, 30)
                        guest
                    }
                    .padding(.vertical)
                    
                    Spacer()
                }
            }
            .alert("Firebase Error", isPresented: $showingAlertForFirebaseError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(K.ErrorHelper.Messages.Network.firebaseConnection.rawValue)
            }

        }
        .preferredColorScheme(.dark)
        .background(weenyWitch.black.edgesIgnoringSafeArea(.all))
    }
    
    var logo: some View {
        Image("SimpleLogo")
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 50)
        
    }
    
    private var orDivider: some View {
        HStack(spacing: 15) {
            
            Rectangle()
                .fill(weenyWitch.light)
                .frame(height: 1)
            
            Text("OR")
                .foregroundColor(weenyWitch.lightest)
                .font(.avenirNext(size: 20))
            
            Rectangle()
                .fill(weenyWitch.light)
                .frame(height: 1)
            
        }
        .padding(.horizontal, 30)
        .padding(.top, 25)
    }
    
    //MARK: - Other Options
    
    private var guest: some View {
        Text("Continue As Guest")
            .font(.avenirNext(size: 23))
            .fontWeight(.light)
            .italic()
            .foregroundColor(weenyWitch.orange)
            .onTapGesture(perform: continueAsGuestTapped)
            .padding()
    }
    
    private func continueAsGuestTapped() {
        
        Authorization.instance.anonymousSignIn { error in
            
            if error == .troubleConnectingToFirebase {
                
                self.firebaseErrorMessage = error.message()
                
                self.showingAlertForFirebaseError = true
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
