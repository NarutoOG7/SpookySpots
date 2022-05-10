//
//  SlideOverCard.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct SlideOverCard<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.middle
    @Binding var canSlide: Bool
    var color: Color
    var handleColor: Color
    
    var content: () -> Content
    var body: some View {
        
        let drag = DragGesture()
            .updating($dragState) { (drag, state, transaction) in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return VStack {

            Handle(color: handleColor)
                    .padding(.bottom, 5)
            self.content()
                Spacer()
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(color)
        .cornerRadius(10)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10)
        .offset(y: self.position.rawValue + self.dragState.translation.height)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragState.isDragging)
        .gesture(canSlide ? drag : nil)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.rawValue + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition
        
        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }
        
        if (cardTopEdgeLocation - positionAbove.rawValue) < (positionBelow.rawValue - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

struct SlideOverCard_Previews: PreviewProvider {
    static var previews: some View {
        SlideOverCard(canSlide: .constant(true), color: Color.black, handleColor: .white) {
            VStack {
                Text("Hello")
                    .foregroundColor(Color.white)
                Text("My name is Spencer.")
                Text("I have all the money I will ever need.")
            }
        }
    }
}


//MARK: - Drag State
enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}


//MARK: - Card Position
enum CardPosition: CGFloat {
    case bottom = 600
    case middle = 300
    case top = 70
}


//MARK: - Handle
struct Handle: View {
    
    var color: Color
    
    private let handleThickness = CGFloat(5.0)
    
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(color)
            .padding(10)
    }
}

