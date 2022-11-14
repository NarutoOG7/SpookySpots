//
//  NotificationBanner.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/27/22.
//

import SwiftUI

struct NotificationBanner: View {
    
    let color: Color
    let messageColor: Color
    
    @Binding var message: String
    @Binding var isVisible: Bool
    
    @ObservedObject var errorManager = ErrorManager.instance
    
    var body: some View {
        GeometryReader { geo in
            if isVisible {
                VStack {
                    ZStack {
                        banner
                        messageView
                            .offset(y: 20)
                    }
                    Spacer()
                }
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            isVisible = false
                        }
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                        self.isVisible = false
                        self.errorManager.shouldDisplay = false
                    }
                }
                .offset(y: -(geo.size.height / 5))
            
            }
        }
        
    }
    
    private var banner: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.size.width, height: 125)
            .foregroundColor(color)
    }
    
    private var messageView: some View {
        Text(message)
            .foregroundColor(messageColor)
            .font(.subheadline)
    }
}

struct NotificationBanner_Previews: PreviewProvider {
    static var previews: some View {
        NotificationBanner(color: .red,
                           messageColor: .white,
                           message: .constant("This is going well."),
                           isVisible: .constant(true))
    }
}
