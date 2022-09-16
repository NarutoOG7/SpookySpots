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
