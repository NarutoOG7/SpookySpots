//
//  AddLocationView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/19/22.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct AddLocationView: View {
    
    @State var nameInput = ""
    
    @State var addressInput = ""
    @State var cityInput = ""
    @State var stateInput = ""
    @State var countryInput = ""
    @State var zipCodeInput = ""
    
    @State var showingImagePicker = false
    @State var inputImage: UIImage?
    @State var imageToDisplay: Image?
    
    @State var imageSourceInput = ""
    
    @State var descriptionInput = ""
    
    @State var moreInfoLinkInput = ""
        
    @State var shouldDisplayOwnershipQuestionAlert = false
    @State var shouldDisplayImageUnavailableWithoutRightsAlert = false
    @State var shouldDipslayLocationSubmitConfirmationAlert = false
    
    @State var shouldShowLocationNameError = false
    @State var shouldShowStreetErrorMessage = false
    @State var shouldShowCityErrorMessage = false
    @State var shouldShowStateErrorMessage = false
    @State var shouldShowCountryErrorMessage = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init() {
        let textViewAppearance = UITextView.appearance()
          textViewAppearance.backgroundColor = .clear
        textViewAppearance.tintColor = .orange
      }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                imagePicker
                if imageToDisplay != nil {
                    imageSource
                }
                name
                address
                description
                moreInfoLinkView
                submitButton
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .alert("STOP", isPresented: $shouldDisplayOwnershipQuestionAlert, actions: {
            Button("YES", role: .cancel, action: {})
            Button("NO", role: .destructive, action: { self.shouldDisplayImageUnavailableWithoutRightsAlert = true })
        }, message: {
            Text("Do you own this image or have permission to upload?")
        })
        
        .alert("Image Unavailable", isPresented: $shouldDisplayImageUnavailableWithoutRightsAlert, actions: {
            Button("OK", role: .cancel, action: { self.imageToDisplay = nil })
        }, message: {
            Text("Apologies, but we cannot use images we don't have permission for.")
        })
        
        .alert("Location Submitted!", isPresented: $shouldDipslayLocationSubmitConfirmationAlert, actions: {
            Button("Awesome!", role: .destructive, action: { self.submitConfirmed() })
            Button("Whoops, UNDO", role: .cancel, action: {})
        })
        
        .background(K.Colors.WeenyWitch.black)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imagePicker: some View {
        let screen = UIScreen.main.bounds.size
        return Button {
            self.showingImagePicker = true
        } label: {
            if imageToDisplay != nil {
                imageToDisplay?
            .resizable()
            .frame(width: screen.width, height: screen.height / 4)
            } else {
                Image(K.Images.placeholder)
                    .resizable()
                    .frame(width: screen.width, height: screen.height / 4)

            }
        }
        .onChange(of: inputImage) { _ in
            loadImage()
        }

    }
    
    private var imageSource: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $imageSourceInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Photographer Name (optional)",
            errorMessage: "",
            shouldShowErrorMessage: .constant(false))
     
    }
    
    private var name: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $nameInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Location Name",
            errorMessage: "Please provide a name for this place.",
            shouldShowErrorMessage: $shouldShowLocationNameError)
    }

    //MARK: - Address
    private var address: some View {
        VStack {
            streetAddress
            cityAddress
            stateAddress
            countryAddress
            zipCodeView
        }
    }
    
    private var streetAddress: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $addressInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Street Address",
            errorMessage: "Please provide a street address.",
            shouldShowErrorMessage: $shouldShowStreetErrorMessage)

        
    }
    private var cityAddress: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $cityInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "City",
            errorMessage: "Please provide a city.",
            shouldShowErrorMessage: $shouldShowCityErrorMessage)
    }
    private var stateAddress: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $stateInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "State",
            errorMessage: "Please provide a state.",
            shouldShowErrorMessage: $shouldShowStateErrorMessage)
    }
    private var countryAddress: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $countryInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Country",
            errorMessage: "Please provide a country.",
            shouldShowErrorMessage: $shouldShowCountryErrorMessage)
    }
    private var zipCodeView: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $zipCodeInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Zip Code (optional)",
            errorMessage: "",
            shouldShowErrorMessage: .constant(false))
        .keyboardType(.numberPad)
    }
    
    var description: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return TextEditor(text: $descriptionInput)
            .placeholder(when: descriptionInput.isEmpty, alignment: .topLeading, placeholder: {
                Text("Description (optional)")
                    .foregroundColor(weenyWitch.light)
                    .padding(.top, 7)
                    .padding(.leading, 5)
            })
            .padding()
            .frame(height: 250)
            .foregroundColor(weenyWitch.orange)
            
            .overlay(
                
            RoundedRectangle(cornerRadius: 16)
                .stroke(weenyWitch.orange, lineWidth: 0.5)
            ).padding()
            .padding(.top, 20)

    }
    
    var moreInfoLinkView: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return UserInputCellWithIcon(
            input: $moreInfoLinkInput,
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "More Info Link (optional)",
            errorMessage: "",
            shouldShowErrorMessage: .constant(false))
    }
    
    //MARK: - Submit Button
    
    var submitButton: some View {
        let weenyWitch = K.Colors.WeenyWitch.self
        return Button(action: submitTapped) {
            Capsule()
                .fill(weenyWitch.orange)
                .frame(width: 150, height: 45)
                .overlay(Text("Submit")
                    .foregroundColor(weenyWitch.brown))
            
        }
    }
    
    //MARK: - Methods
    
    func submitTapped() {
        checkRequiredFields()
        if requisiteFieldsAreFilled() {
            self.shouldDipslayLocationSubmitConfirmationAlert = true
        } else {
            // show error for needed fields
        }
    }

    func submitConfirmed() {
        // Submit Location To Firebase Bucket 'User Added Locations'
        let address = Address(address: addressInput, city: cityInput, state: stateInput, zipCode: zipCodeInput, country: countryInput)
        let location = LocationData(id: 0, name: nameInput, address: address, description: descriptionInput, moreInfoLink: moreInfoLinkInput, review: nil, locationType: nil, tours: nil, imageName: nil, distanceToUser: nil, price: nil)
        
        FirebaseManager.instance.addUserCreatedLocationToBucket(location, inputImage)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        imageToDisplay = Image(uiImage: inputImage)
        self.shouldDisplayOwnershipQuestionAlert = true
    }
    
    func requisiteFieldsAreFilled() -> Bool {
        return nameInput != "" &&
        addressInput != "" &&
        cityInput != "" &&
        stateInput != "" &&
        countryInput != "" &&
        zipCodeInput != ""
    }
    
    func checkRequiredFields() {
        
        if nameInput == "" {
            self.shouldShowLocationNameError = true
        } else {
            self.shouldShowLocationNameError = false
        }
        
        if addressInput == "" {
            self.shouldShowStreetErrorMessage = true
        } else {
            self.shouldShowStreetErrorMessage = false
        }
        
        if cityInput == "" {
            self.shouldShowCityErrorMessage = true
        } else {
            self.shouldShowCityErrorMessage = false
        }
        
        if stateInput == "" {
            self.shouldShowStateErrorMessage = true
        } else {
            self.shouldShowStateErrorMessage = false
        }
        
        if countryInput == "" {
            self.shouldShowCountryErrorMessage = true
        } else {
            self.shouldShowCountryErrorMessage = false
        }
    }
}

//MARK: - Preview
struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView()
    }
}

//MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
    

}
