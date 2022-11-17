//
//  ChangeStartAndStop.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit


struct ChangeStartAndStop: View {
    
    @ObservedObject var viewModel: ChangeStartStopViewModel
    @ObservedObject var errorManager: ErrorManager
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            
            VStack {
                
                StartStopCustomTextField(
                    textInput: $viewModel.startInput,
                    placeholderText: $viewModel.startPlaceholder,
                    editedField: $viewModel.editedField,
                    type: .start,
                    changeStartStopViewModel: viewModel)
                .padding()
                StartStopCustomTextField(
                    textInput: $viewModel.endInput,
                    placeholderText: $viewModel.endPlaceholder,
                    editedField: $viewModel.editedField,
                    type: .end,
                    changeStartStopViewModel: viewModel)
                .padding(.horizontal)
                .padding(.bottom)
                
                if viewModel.shouldShowCurrentLocationOption() {
                    currentLocationButton
                }
                
                searchResultsList
                
            }
        }
        .padding(.top)
        
        .background(weenyWitch.black)
        
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                cancelButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                doneButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.setPlaceholder()
        }
        .alert("Location Not Found!", isPresented: $viewModel.shouldShowCurrentLocationFailedErrorMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You must allow the app permission to get your current location. Please visit your device settings.")
        }
        
    }
    
    private var searchResultsList: some View {
        List(viewModel.localSearchService.locationsList) { location in
            Button(action: {
                viewModel.locationChosen(location)
            }, label: {
                VStack(alignment: .leading) {
                    Text(location.name ?? "").truncationMode(.tail)
                        .foregroundColor(weenyWitch.light)
                        .font(.avenirNext(size: 20))
                    Text(location.placemark.postalAddress?.streetCityState() ?? "")
                        .font(.avenirNext(size: 17))
                        .foregroundColor(weenyWitch.orange)
                    
                }
            })
            .listRowBackground(Color.clear)
            
        }
        .modifier(ClearListBackgroundMod())
    }
    
    private var errorBanner: some View {
        
        NotificationBanner(
            message: .constant("You must allow the app access to your current location."),
            isVisible: $viewModel.shouldShowCurrentLocationFailedErrorMessage,
            errorManager: errorManager)
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                viewModel.shouldShowCurrentLocationFailedErrorMessage = false
            }
        }
    }
    
    //MARK: - Buttons
    
    var cancelButton: some View {
        Button(action: {
            cancel()
        }, label: {
            Text("Cancel")
                .font(.avenirNext(size: 20))
                .fontWeight(.light)
            
        })
    }
    
    var doneButton: some View {
        Button(action: {
            viewModel.addStartAndStopToTrip()
            self.dismiss.callAsFunction()
        }, label: {
            Text("Done")
                .font(.avenirNext(size: 20))
                .fontWeight(.medium)
        })
    }
    
    private var currentLocationButton: some View {
        Button(action: viewModel.currentLocationTapped) {
            Text("Current Location")
                .foregroundColor(weenyWitch.orange)
                .font(.avenirNext(size: 20))
        }
    }
    
    //MARK: - Methods
    
    func cancel() {
        self.dismiss.callAsFunction()
    }

    
}


struct ChangeStartAndStop_Previews: PreviewProvider {
    static var previews: some View {
        ChangeStartAndStop(viewModel: ChangeStartStopViewModel(),
                           errorManager: ErrorManager())
    }
}

