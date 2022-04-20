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
    
    var body: some View {
        VStack {
            Spacer()
            displayName
            emailView
            Spacer()
            saveButton
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
                        Text(userStore.user.email)
                            .foregroundColor(.black)
                    }
                    .font(.title)
                    .onChange(of: emailInput) { _ in
                        wasEdited = true
                    }
                Divider().foregroundColor(.gray)
            }
        }.padding()
    }
    
    private var saveButton: some View {
        Button(action: saveTapped) {
            Text("SAVE")
        }.disabled(!wasEdited)
        
    }
    
    private func saveTapped() {
        
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
