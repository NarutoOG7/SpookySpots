//
//  Constants.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import SwiftUI


//MARK: - K for Constant
enum K {
    
    static let adminKey = "7JSe9iXzgrbvEdL7Ql7yOx7AIs72"
    
    
    //MARK: - Colors
    enum Colors {
        
        enum WeenyWitch {
            static let lightest = Color("WeenyWitch/ColorZero")
            static let lighter = Color("WeenyWitch/ColorOne")
            static let light = Color("WeenyWitch/ColorTwo")
            static let orange = Color("WeenyWitch/ColorThree")
            static let brown = Color("WeenyWitch/ColorFour")
            static let black = Color("WeenyWitch/ColorFive")
            

            
//
//            static let lightest = Color("PurpleSky/ColorOne")
//            static let lighter = Color("PurpleSky/ColorOne")
//            static let light = Color("PurpleSky/ColorOne")
//            static let orange = Color("PurpleSky/ColorThree")
//            static let brown = Color("PurpleSky/ColorOne")
//            static let black = Color("PurpleSky/ColorZero")
        }
        
        enum PurpleSky {
            static let black = Color("PurpleSky/ColorZero")
            static let blue = Color("PurpleSky/ColorOne")
            static let darkPurple = Color("PurpleSky/ColorTwo")
            static let lightPurple = Color("PurpleSky/ColorThree")
        }
        
        enum LetsHang {
            static let lightBrown = Color("LetsHang/LightBrown")
            static let purple = Color("LetsHang/Purple")
            static let orange = Color("LetsHang/Orange")
            static let brown = Color("LetsHang/Brown")
            static let DarkPurple = Color("LetsHang/DarkPurple")
        }
        
    }
    
    
    //MARK: - Error Messages
    
    enum ErrorMessages {

        enum ErrorType {
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
                let authMessages = K.ErrorMessages.Auth.self
                let networkMessages = K.ErrorMessages.Network.self
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
