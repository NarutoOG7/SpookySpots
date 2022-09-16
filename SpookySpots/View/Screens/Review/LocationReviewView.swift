//
//  LocationReviewView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/18/22.
//

import SwiftUI

struct LocationReviewView: View {
    
    @Binding var location: LocationModel
    @Binding var isPresented: Bool
    @Binding var review: ReviewModel?
    
    @State var titleInput: String = ""
    @State var pickerSelection: Int = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
    @State var nameInput: String = ""
    
    @State var shouldShowTitleErrorMessage = false
    @State var shouldShowDescriptionErrorMessage = false
    @State var shouldShowFirebaseError = false
    @State var shouldShowSuccessMessage = false
    
    @State var firebaseErrorMessage = ""
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    @Environment(\.presentationMode) var presentationMode
        
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            K.Colors.WeenyWitch.black
                .edgesIgnoringSafeArea(.vertical)
        
            VStack(spacing: 20) {
                stars
                    .padding(.vertical, 20)
                title
                description
                anonymousOption
                submitButton
            }
            .padding()
            .navigationTitle(location.location.name)
            
            firebaseErrorBanner

        }
        .alert("Success", isPresented: $shouldShowSuccessMessage, actions: {
            Button("OK", role: .cancel, action: { self.presentationMode.wrappedValue.dismiss() })
        })
        
        .onSubmit {
            switch focusedField {
            case .title:
                focusedField = .description
            case .description:
                focusedField = .username
            default: break
            }
        }
    }
    
    private var title: some View {
        UserInputCellWithIcon(
            input: $titleInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Title",
            errorMessage: "Please add a title.",
            shouldShowErrorMessage: $shouldShowTitleErrorMessage,
            isSecured: .constant(false))
        .focused($focusedField, equals: .title)
        .submitLabel(.next)
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
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Description",
            errorMessage: "Please add a description.",
            shouldShowErrorMessage: $shouldShowDescriptionErrorMessage,
            isSecured: .constant(false))
        .focused($focusedField, equals: .description)
        .submitLabel(.next)
    }
    
    private var anonymousOption: some View {
        VStack(spacing: 12) {
            if !isAnonymous {
                let weenyWitch = K.Colors.WeenyWitch.self
                UserInputCellWithIcon(
                    input: $nameInput,
                    primaryColor: weenyWitch.orange,
                    accentColor: weenyWitch.light,
                    icon: nil,
                    placeholderText: userStore.user.name,
                    errorMessage: "",
                    shouldShowErrorMessage: .constant(false),
                    isSecured: .constant(false))
                .focused($focusedField, equals: .username)
                .submitLabel(.done)
            }
            Toggle(isOn: $isAnonymous) {
                Text("Leave Review Anonymously?")
                    .italic()
                    .font(.caption)
                    .foregroundColor(K.Colors.WeenyWitch.lighter)
            }.padding(.horizontal)
                .tint(K.Colors.WeenyWitch.orange)
        }
    }
    //MARK: - Error Banner
    private var firebaseErrorBanner: some View {
        
            NotificationBanner(color: weenyWitch.orange, messageColor: weenyWitch.lightest, message: $firebaseErrorMessage, isVisible: $shouldShowFirebaseError)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.shouldShowFirebaseError = false
                }
            }
    }
    
    private var submitButton: some View {
        let isReview = review != nil
        let isDisabled = !requisiteFieldsAreFilled() || !isUpdated()
        let color = isDisabled ? K.Colors.WeenyWitch.lighter.opacity(0.1) : K.Colors.WeenyWitch.orange
        return Button(action: submitTapped) {
            Text(isReview && isUpdated() ? "Update" : "Submit")
                .foregroundColor(color)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color))
            
        }
        .disabled(isDisabled)
    }
    
    private func submitTapped() {
        
        checkRequiredFieldsAndAssignErrorMessagesAsNeeded()
        
        if requisiteFieldsAreFilled() {
            
            let name = nameInput == "" ? userStore.user.name : nameInput
            let rev = ReviewModel(
                id: "",
                rating: pickerSelection,
                review: descriptionInput,
                title: titleInput,
                username: isAnonymous ? "Anonymous" : name,
                locationID: "\(location.location.id)",
                locationName: location.location.name)
            
            if self.review != nil && isUpdated() {
                firebaseManager.updateReviewInFirestore(rev, forID: self.review?.id ?? rev.id) { error in
                    if let error = error {
                        self.firebaseErrorMessage = "There was an error updating the review. Please check your connection and try again."
                        self.shouldShowFirebaseError = true
                        print("Error updating review : \(error)")
                    }
                    self.location.reviews.append(rev)
                    LocationStore.instance.switchNewLocationIntoAllBucketsIfExists(location)
                    self.shouldShowSuccessMessage = true
                }
            } else {
                firebaseManager.addReviewToFirestoreBucket(rev, location: location.location) { error in
                    if let error = error {
                        print("Error saving review: \(error)")
                        self.firebaseErrorMessage = "There was an error saving your review. Please check your connection and try again."
                        self.shouldShowFirebaseError = true
                    }
                    self.location.reviews.append(rev)
                    LocationStore.instance.switchNewLocationIntoAllBucketsIfExists(location)
                    self.shouldShowSuccessMessage = true
                }
            }
        }
    }
    
    private func requisiteFieldsAreFilled() -> Bool {
        return titleInput != "" &&
        descriptionInput != ""
    }
    
    private func checkRequiredFieldsAndAssignErrorMessagesAsNeeded() {
        if titleInput == "" {
            self.shouldShowTitleErrorMessage = true
        } else {
            self.shouldShowTitleErrorMessage = false
        }
        
        if descriptionInput == "" {
            self.shouldShowDescriptionErrorMessage = true
        } else {
            self.shouldShowDescriptionErrorMessage = false
        }
    }
    
    private func isUpdated() -> Bool {
        titleInput != review?.title ||
        descriptionInput != review?.review ||
        pickerSelection != review?.rating ||
        nameInput != review?.username
    }
    
    //MARK: - Field
    enum Field {
        case title, description, username
    }
}

struct LocationReviewView_Previews: PreviewProvider {
    static var previews: some View {
        LocationReviewView(location: .constant(LocationModel(location: .example, imageURLs: [], reviews: [])), isPresented: .constant(true), review: .constant(nil))
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
    @Binding var isSecured: Bool
    var canSecure = false
    var hasDivider = true
    var boldText = false
    
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            HStack(spacing: 15) {
                if let icon = icon {
                    if canSecure == true {
                        Button {
                            isSecured.toggle()
                        } label: {
                            icon.foregroundColor(primaryColor)
                        }

                    } else {
                    icon
                        .foregroundColor(primaryColor)
                    }
                }
                
                if isSecured {
                    
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
        
        .onAppear {
            let textViewAppearance = UITextField.appearance()
            textViewAppearance.backgroundColor = .clear
            textViewAppearance.tintColor = UIColor(K.Colors.WeenyWitch.orange)
            
        }
    }
}
