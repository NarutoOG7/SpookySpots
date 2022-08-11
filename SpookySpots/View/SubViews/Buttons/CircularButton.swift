//
//  CircularButton.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct CircularButton: View {

    var body: some View {
        VStack {
            CircleButton(size: .small, image: Image(systemName: "arrow.triangle.turn.up.right.diamond.fill"), outlineColor: .blue, iconColor: .white, backgroundColor: .blue, clicked: {
                
            })
            
            
            StackedCircleButton(size: .small, mainImage: Image(systemName: "map.fill"), secondaryImage: Image(systemName: "minus"), outlineColor: .white, iconColor: .white, backgroundColor: .blue) {
                
            }
            StackedCircleButton(size: .medium, mainImage: Image(systemName: "map.fill"), secondaryImage: Image(systemName: "plus"), outlineColor: .white, iconColor: .white, backgroundColor: .blue) {
                
            }
        }
        
    }
}

struct CircleButton: View {
    var size: SizesForCustomButtons
    var image: Image
    var outlineColor: Color
    var iconColor: Color
    var backgroundColor: Color
    var clicked: (() -> Void)
    
    var body: some View {
        Button(action: clicked) {
            ZStack {
                Circle()
                    .stroke(outlineColor, lineWidth: 3)
                    .background(Circle()
                                    .foregroundColor(backgroundColor))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.rawValue)
                    .shadow(color: backgroundColor, radius: 2, x: 0, y: 1)
                image
                    .resizable()
                    .accentColor(iconColor)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: size.rawValue * (size == .small ? 0.55 : 0.7))
            }
        }
    }
}

struct StackedCircleButton: View {
    var size: SizesForCustomButtons
    var mainImage: Image
    var secondaryImage: Image
    var outlineColor: Color
    var iconColor: Color
    var backgroundColor: Color
    var clicked: (() -> Void)
    
    var body: some View {
        Button(action: clicked) {
            ZStack {
            ZStack {
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
                    .background(Circle()
                                    .foregroundColor(secondImageIsMinus() ? .blue : .white))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.rawValue)
                mainImage
                    .resizable()
                    .accentColor(secondImageIsMinus() ? .white : .blue)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: size.rawValue * 0.7)
            }
        
            ZStack {
                Circle()
                    .stroke(secondImageIsMinus() ? Color.blue : Color.white, lineWidth: 3)
                    .background(Circle()
                                    .foregroundColor(secondImageIsMinus() ? .white : .blue))
                    .frame(width: size.rawValue * 0.47, height: size.rawValue * 0.47)
                    secondaryImage
                        .resizable()
                        .accentColor(secondImageIsMinus() ? .blue : .white)
                        .frame(width: size.rawValue * 0.29, height: secondImageIsMinus() ? 3 : size.rawValue * 0.29)
                
            }
            .offset(x: size.rawValue * 0.3, y: size.rawValue * 0.3)
            }
        }
        .shadow(color: Color(#colorLiteral(red: 0.06314038817, green: 0.4441809558, blue: 0.9376586294, alpha: 0.5)), radius: 2, x: 0, y: 1)
        .frame(width: 68, height: 68)
    }
    
    private func secondImageIsMinus() -> Bool {
        secondaryImage == Image(systemName: "minus")
    }
}

//MARK: - Sizes

enum SizesForCustomButtons: CGFloat {
    case small = 50
    case medium = 68
}



struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularButton()
    }
}
