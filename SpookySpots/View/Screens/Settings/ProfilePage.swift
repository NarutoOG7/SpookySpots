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
    
    @State var wasEdited = false
    
    @State var displayNameInput = ""
    @State var emailInput = ""
    
    @State var deleteAcctAlertShown = false

    
    var body: some View {
        VStack {
            Spacer()
            displayName
            emailView
            Spacer()
            saveButton
            Spacer()
            deleteAcctButton
            Spacer()
        }
        /////MARK: - Delete Account Confirmation Alert
        .alert("Are You Sure?", isPresented: $deleteAcctAlertShown) {
            Button(role: .destructive, action: confirmDeleteTapped) {
                Text("DELETE")
            }
            Button("CANCEL", role: .cancel) { }
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
                        Text(userStore.user.user.name)
                            .foregroundColor(.black)
                    }
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.title)
                    .onChange(of: displayNameInput) { _ in
                        wasEdited = true
                    }
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
                        Text(userStore.user.user.email)
                            .foregroundColor(.black)
                    }
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.title)
                    .onChange(of: emailInput) { _ in
                        wasEdited = true
                    }
                Divider().foregroundColor(.gray)
            }
        }.padding()
    }
    
    //MARK: - Buttons
    
    private var saveButton: some View {
        Button(action: saveTapped) {
            Text("SAVE")
        }.disabled(!wasEdited)
            .padding()
        
    }
    
    private var deleteAcctButton: some View {
        HStack {
            Spacer()
            Spacer()
        Button(action: deleteAcctTapped) {
            Text("Delete Account")
                .font(.callout)
                .fontWeight(.light)
                .foregroundColor(Color.gray)
        }.padding(.horizontal)
        }
    }
    
    //MARK: - Methods
    
    private func saveTapped() {
        auth.setCurrentUsersName(displayNameInput)
    }
    
    
    private func deleteAcctTapped() {
        self.deleteAcctAlertShown = true
    }
    
    private func confirmDeleteTapped() {
        auth.deleteUserAccount { error in
            self.deleteAcctAlertShown = true
        } success: { result in
            if result == true {
                
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
