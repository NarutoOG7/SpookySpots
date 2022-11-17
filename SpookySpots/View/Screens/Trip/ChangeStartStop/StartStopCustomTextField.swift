//
//  StartStopCustomTextField.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/9/22.
//

import SwiftUI

struct StartStopCustomTextField: View {
    
    @Binding var textInput: String
    @Binding var placeholderText: String
    @Binding var editedField: FieldType
    
    var type: FieldType
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @ObservedObject var changeStartStopViewModel: ChangeStartStopViewModel
    
    var body: some View {
        
        HStack {
            labelTextView
            txtField
        }
        
        .onAppear {
            UITextField.appearance().tintColor = UIColor(weenyWitch.orange)
        }
        .padding()
        .overlay(Capsule().stroke(weenyWitch.orange))
    }
    
    private var txtField: some View {
        TextField(placeholderText, text: $textInput) { startedEditing in
            self.editedField = type
        } onCommit: {
            self.editedField = .none
        }
        .placeholder(when: textInput.isEmpty) {
            Text(placeholderText)
                .foregroundColor(weenyWitch.lightest)
                .font(.avenirNext(size: 18))
        }
        .foregroundColor(weenyWitch.lightest)
        .font(.avenirNext(size: 18))
        .offset(x: 10, y: 1)
        
        .onChange(of: textInput) { newValue in
            changeStartStopViewModel.buildResultsList(newValue)
        }
    }
    
    private var labelTextView: some View {
        Text(type.labelText)
            .font(.avenirNext(size: 22))
            .foregroundColor(weenyWitch.orange)
            .offset(x: 10)
    }
    
}

struct StartStopCustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        StartStopCustomTextField(
            textInput: .constant("Ball Arena"),
            placeholderText: .constant("Avalanche"),
            editedField: .constant(.start),
            type: .start,
            changeStartStopViewModel: ChangeStartStopViewModel())
    }
}
