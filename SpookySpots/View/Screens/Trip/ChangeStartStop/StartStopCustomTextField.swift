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
    
    @ObservedObject var localSearchService = LocalSearchService.instance
    
    var body: some View {
        
        HStack {
            labelTextView
            txtField
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
        }
        .foregroundColor(weenyWitch.lightest)
        .offset(x: 10, y: 1)
        
        .onChange(of: textInput) { newValue in
            localSearchService.locationsList.removeAll()
            localSearchService.performSearch(from: newValue) { (result) -> (Void) in
                localSearchService.locationsList.append(result)
            }
        }
    }
    
    private var labelTextView: some View {
        Text(type.labelText)
            .font(.title3)
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
            type: .start)
    }
}
