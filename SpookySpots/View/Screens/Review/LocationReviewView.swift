//
//  LocationReviewView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/18/22.
//

import SwiftUI

struct LocationReviewView: View {
    
    @Binding var location: LocationModel
    
    @State var titleInput: String = ""
    @State var pickerSelection: Int = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
    @State var nameInput: String = ""
    
    @State var shouldShowTitleErrorMessage = false
    @State var shouldShowDescriptionErrorMessage = false
    @State var shouldShowUserNameErrorMessage = false
    
    @State var shouldShowSuccessMessage = false
    
    @ObservedObject var userStore = UserStore.instance
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 20) {
            stars
                .padding(.vertical, 20)
            title
            description
            anonymousOption
                .padding(.vertical, 20)
            submitButton
        }
        .padding()
        .navigationTitle(location.location.name)
        
        .alert("Success", isPresented: $shouldShowSuccessMessage, actions: {
            Button("OK", role: .cancel, action: { self.presentationMode.wrappedValue.dismiss() })
        })
    }
    
    private var title: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $titleInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: nil,
            placeholderText: "Title",
            errorMessage: "Please add a title.",
            shouldShowErrorMessage: $shouldShowTitleErrorMessage)
        
    }
    
    private var stars: some View {
        HStack {
            FiveStars(rating: $pickerSelection, isEditable: true, color: K.Colors.WeenyWitch.orange)
        }
    }
    
    private var description: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $descriptionInput,
            primaryColor: weenyWitch.brown,
            accentColor: weenyWitch.lightest,
            icon: nil,
            placeholderText: "Description",
            errorMessage: "Please add a description.",
            shouldShowErrorMessage: $shouldShowDescriptionErrorMessage)
    }
    
    private var anonymousOption: some View {
        VStack {
            Toggle(isOn: $isAnonymous) {
                Text("Leave Review Anonymously?")
                    .italic()
                    .foregroundColor(.brown)
            }.padding(.horizontal)
                .tint(K.Colors.WeenyWitch.orange)
            if !isAnonymous {
                let weenyWitch = K.Colors.WeenyWitch.self
                UserInputCellWithIcon(
                    input: $nameInput,
                    primaryColor: weenyWitch.brown,
                    accentColor: weenyWitch.lightest,
                    icon: nil,
                    placeholderText: userStore.user.name,
                    errorMessage: "Please add a name or make the review Anonymous.",
                    shouldShowErrorMessage: $shouldShowUserNameErrorMessage)
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitTapped) {
            Text("Submit")
                .foregroundColor(K.Colors.WeenyWitch.orange)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(K.Colors.WeenyWitch.black))
            
        }
    }
    
    private func submitTapped() {
        let name = nameInput == "" ? userStore.user.name : nameInput
        let review = ReviewModel(avgRating: 0, lastRating: pickerSelection, lastReview: descriptionInput, lastReviewTitle: titleInput, userName: isAnonymous ? "Anonymous" : name, locationID: "\(location.location.id)")
        FirebaseManager.instance.addReviewToFirestoreBucket(review, locationID: "\(location.location.id)")
        self.shouldShowSuccessMessage = true
        
        var newLocation = location
        newLocation.reviews.append(review)
        LocationStore.instance.switchNewLocationIntoAllBucketsIfExists(newLocation)
        self.location = newLocation

    }
}

struct LocationReviewView_Previews: PreviewProvider {
    static var previews: some View {
        LocationReviewView(location: .constant(LocationModel(id: UUID(), location: .example, imageURLs: [], reviews: [])))
        
    }
}



struct UserInputCellWithIcon: View {
    
    @Binding var input: String
    
    let primaryColor: Color
    let accentColor: Color
    var thirdColor: Color = .clear
    
    //        let cellColor: Color
    //        let dividerColor: Color
    //        let iconColor: Color
    //        let textColor: Color
    //        let placeholderColor: Color
    
    let icon: Image?
    let placeholderText: String
    
    let errorMessage: String
    @Binding var shouldShowErrorMessage: Bool
    
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            HStack(spacing: 15) {
                if let icon = icon {
                    
                    icon
                        .foregroundColor(primaryColor)
                }
                
                
                
                TextField("", text: self.$input)
                    .disableAutocorrection(true)
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
            
            Divider().background(primaryColor)
        }
        .padding(.horizontal)
        .padding(.top, 40)
        
        .onAppear {
            let textViewAppearance = UITextField.appearance()
            textViewAppearance.backgroundColor = .clear
            textViewAppearance.tintColor = UIColor(K.Colors.WeenyWitch.orange)
            
        }
    }
}
