//
//  UserInputCellWithIcon.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI


struct UserInputCellWithIcon: View {
    
    @Binding var input: String
    @Binding var shouldShowErrorMessage: Bool
    @Binding var isSecured: Bool
    
    let primaryColor: Color
    let accentColor: Color
    var thirdColor: Color = .clear
    
    let icon: Image?
    let placeholderText: String
    
    let errorMessage: String
    var canSecure = false
    var hasDivider = true
    var boldText = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowErrorMessage {
                errorView
            }
            HStack(spacing: 15) {

                iconView
                
                if isSecured {
                    
                    secureFieldView
                    
                } else {
                    
                    TextField("", text: self.$input)
                        .disableAutocorrection(true)
                        .font(.title3.weight(boldText ? .bold : .regular))
                        .textInputAutocapitalization(.never)
                        .foregroundColor(primaryColor)
                        .placeholder(when: input.isEmpty) {
                            Text(placeholderText)
                                .foregroundColor(accentColor)
                        }
                        .onChange(of: input) { newValue in
                            if !newValue.isEmpty {
                                self.shouldShowErrorMessage = false
                            }
                        }
                    
                }
            }
            if hasDivider {
                Divider().background(primaryColor)
            }
        }
        .padding(.horizontal)
        .padding(.top, 40)
        
    }
    
    private var errorView: some View {
        Text(errorMessage)
            .foregroundColor(.red)
            .font(.caption)
    }
    
    private var iconView: some View {
        if let icon = icon {
            if canSecure == true {
                return AnyView(Button {
                    isSecured.toggle()
                } label: {
                    icon.foregroundColor(primaryColor)
                })
                
            } else {
                return AnyView(icon
                    .foregroundColor(primaryColor))
            }
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var secureFieldView: some View {
        SecureField(input, text: self.$input)
            .disableAutocorrection(true)
            .font(.title3.weight(boldText ? .bold : .regular))
            .textInputAutocapitalization(.never)
            .foregroundColor(primaryColor)
            .placeholder(when: self.input.isEmpty) {
                Text(placeholderText)
                    .foregroundColor(accentColor)
            }
            .onChange(of: input) { newValue in
                if !newValue.isEmpty {
                    self.shouldShowErrorMessage = false
                }
            }
    }
}


struct UserInputCellWithIcon_Previews: PreviewProvider {
    static var previews: some View {
        UserInputCellWithIcon(input: .constant("No Good"),
                              shouldShowErrorMessage: .constant(false),
                              isSecured: .constant(false),
                              primaryColor: .red,
                              accentColor: .blue,
                              icon: nil,
                              placeholderText: "Giants",
                              errorMessage: "Deflected")
    }
}
