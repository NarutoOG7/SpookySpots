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
    
    @State private var shouldShowFirebaseError = false
    @State private var firebaseErrorMessage = ""

    @Environment(\.dismiss) var dismiss
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
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
        .background(weenyWitch.black)
        /////MARK: - Delete Account Confirmation Alert
        .alert("Are You Sure?", isPresented: $deleteAcctAlertShown) {
            Button(role: .destructive, action: confirmDeleteTapped) {
                Text("DELETE")
            }
            Button("CANCEL", role: .cancel) { }
        }
        
        .navigationTitle("Profile")
    }
    
    private var displayName: some View {
        HStack(alignment: .center, spacing: 24) {
            Text("Name:")
                .foregroundColor(weenyWitch.orange)
             
                
                TextField("", text: $displayNameInput)
                    .placeholder(when: displayNameInput.isEmpty) {
                        Text(userStore.user.name)
                            .foregroundColor(weenyWitch.lightest)
                    }
                    .foregroundColor(weenyWitch.lightest)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.title2)
                    .onChange(of: displayNameInput) { _ in
                        wasEdited = true
                    }
            
            }.padding()
    }
    
    private var emailView: some View {
        HStack(alignment: .center, spacing: 24) {
            Text("Email:")
                .foregroundColor(weenyWitch.orange)
            
                TextField("", text: $emailInput)
                    .placeholder(when: emailInput.isEmpty) {
                        Text(userStore.user.email)
                            .foregroundColor(weenyWitch.lightest)
                    }
                    .foregroundColor(weenyWitch.lightest)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.title2)
                    .onChange(of: emailInput) { _ in
                        wasEdited = true
                    }
            
        }.padding()
    }
    
    //MARK: - Buttons
    
    private var saveButton: some View {
        Button(action: saveTapped) {
            Text("SAVE")
                .foregroundColor(weenyWitch.orange)
                .padding()
                .overlay(Capsule().stroke(weenyWitch.orange))
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
                .foregroundColor(Color.red.opacity(0.8))
        }.padding(.horizontal)
        }
    }
    
    //MARK: - Methods
    
    private func saveTapped() {
        auth.setCurrentUsersName(displayNameInput) { error in
            self.shouldShowFirebaseError = true
            self.firebaseErrorMessage = error.message()
        }
        self.dismiss.callAsFunction()
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

