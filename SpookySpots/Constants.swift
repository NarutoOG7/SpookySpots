//
//  Constants.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import SwiftUI


//MARK: - K for Constant
enum K {
    
    //MARK: - Colors
    enum Colors {
        
        enum WeenyWitch {
            static let lightest = Color("WeenyWitch/ColorZero")
            static let lighter = Color("WeenyWitch/ColorOne")
            static let light = Color("WeenyWitch/ColorTwo")
            static let orange = Color("WeenyWitch/ColorThree")
            static let brown = Color("WeenyWitch/ColorFour")
            static let black = Color("WeenyWitch/ColorFive")
        }
        
    }
    
    //MARK: - Error Messages
    
    enum ErrorHelper {

        enum ErrorType {
            case email, username, password, confirmPassword, firebase
        }
            
            enum Errors {
                case unrecognizedEmail
                case incorrectEmail
                case insufficientPassword
                case emailInUse
                case emailIsBadlyFormatted
                case incorrectPassword
                case passwordsDontMatch
                case troubleConnectingToFirebase
                case firebaseTrouble
                case failedToSaveUser
        
                func message() -> String {
                    let authMessages = K.ErrorHelper.Messages.Auth.self
                    let networkMessages = K.ErrorHelper.Messages.Network.self
                    switch self {
                        
                    case .unrecognizedEmail:
                        return authMessages.unrecognizedEmail.rawValue
                        
                    case .incorrectEmail:
                        return authMessages.incorrectEmail.rawValue
                        
                    case .insufficientPassword:
                        return authMessages.insufficientPassword.rawValue
                        
                    case .emailInUse:
                        return authMessages.emailInUse.rawValue
                        
                    case .emailIsBadlyFormatted:
                        return authMessages.emailIsBadlyFormatted.rawValue
                        
                    case .incorrectPassword:
                        return authMessages.incorrectPassword.rawValue
                        
                    case .passwordsDontMatch:
                        return authMessages.passwordsDontMatch.rawValue
                        
                    case .troubleConnectingToFirebase:
                        return networkMessages.troubleConnectingToFirebase.rawValue
                        
                    case .firebaseTrouble:
                        return networkMessages.firebaseTrouble.rawValue
                        
                    case .failedToSaveUser:
                        return authMessages.failedToSaveUser.rawValue
                        
                    }
                }
        }
        
        struct Messages {
            
            enum Review: String {
                case savingReview = "There was an error saving your review. Please check your connection and try again."
                case updatingReview = "There was an error updating the review. Please check your connection and try again."
            }
            enum Auth: String {
                case usernameBlank = "Please provide a name."
                case failToSignOut = "There was an error signing out of your account. Check your connection and try again."
                case failedToSaveUser = "There was a problem saving the user"
                
                case emailBlank = "Please provide an email address."
                case unrecognizedEmail = "This email isn't recognized."
                case incorrectEmail = "Email is invalid."
                case emailIsBadlyFormatted = "This is not recognized as an email."
                case emailInUse = "This email is already in use."
                
                case passwordBlank = "Please provide a password."
                case incorrectPassword = "Password is incorrect."
                case insufficientPassword = "Password must be at least 6 characters long."
                case passwordsDontMatch = "Passwords DO NOT match"
                
            }
            enum Network: String {
                case troubleConnectingToFirebase = "There seems to be an issue with the connection to firebase."
                case firebaseTrouble = "There was an issue creating your account."
                case firebaseConnection = "There was an error with firebase. Check your connection and try again."
            }
        }
    }
    
    
    //MARK: - Images
    
    enum Images {
        enum Trip {
            static let completed = Image(systemName: "checkmark.circle")
            static let currentLocationIcon = Image("CurrentLocationIcon")
            static let currentLocationIconWithDots = Image("CurrentLocationMarker.WithDots.orange")
            static let lastDestinationIcon = Image("DestinationPin.WithDots.TopSide.orange")
            static let destinationIcon = Image("DestinationPin.WithDots.bothSides.orange")
        }
        static let splashOne = Image("SplashOne")
        static let splashTwo = Image("SplashTwo")
        static let logo = Image("Logo")
        static let paperBackground = Image("PaperBackground")
        static let directions = Image(systemName:"arrow.triangle.turn.up.right.diamond.fill")
        static let share = Image(systemName: "square.and.arrow.up")
        static let placeholder = Image("placeholder")
        
    }
}
