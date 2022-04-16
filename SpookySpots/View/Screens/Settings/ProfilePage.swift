//
//  ProfilePage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct ProfilePage: View {
    
    var userStore = UserStore.instance
    var auth = Authorization.instance
    
    @State var signOutAlertShown = false
    
    @State var displayNameInput = ""
    @State var emailInput = ""
    
    var body: some View {
        VStack {
            Spacer()
            displayName
            emailView
            Spacer()
            signOutButton
        }
        .alert("Failed To Sign Out", isPresented: $signOutAlertShown) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthErrorTypes.failToSignOut.rawValue)
        }
    }
    
    private var displayName: some View {
        HStack {
            Text("Name:")
                .foregroundColor(Color.gray)
                .padding(.trailing, 40)
            VStack {
                
                TextField("", text: $displayNameInput)
                    .placeholder(when: displayNameInput.isEmpty) {
                        Text(userStore.user.name)
                            .foregroundColor(.black)
                    }
                    .font(.title)
                
                Divider().foregroundColor(.gray)
            }
        }.padding()
    }
    
    private var emailView: some View {
        HStack {
            Text("Email:")
                .foregroundColor(Color.gray)
                .padding(.trailing, 40)
            
            VStack {
                TextField("", text: $emailInput)
                    .placeholder(when: emailInput.isEmpty) {
                        Text(userStore.user.email)
                            .foregroundColor(.black)
                    }
                    .font(.title)
                
                Divider().foregroundColor(.gray)
            }
        }.padding()
    }
    
    
    private var signOutButton: some View {
        Button(action: signOutTapped) {
            Text("SIGN OUT")
                .fontWeight(.medium)
                .foregroundColor(.red)
        }.padding(.bottom, 70)
    }
    
    
    private func signOutTapped() {
        auth.signOut { error in
            if error == .failToSignOut {
                self.signOutAlertShown = true
            }
        }
    }
    
    
}

//MARK: - Preview
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}




//MARK: - TextViewPlaceholderTextColor

extension TextField {
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
