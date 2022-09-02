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
    
    var body: some View {
        if isVisible {
        VStack {
        ZStack {
            banner
            messageView
                .offset(y: 20)
        }
            Spacer()
        }
        .position(x: 210, y: 50)
        }
    }
    
    private var banner: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.size.width + 30, height: 125)
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
        NotificationBanner(color: .red, messageColor: .white, message: .constant("You don't belong here"), isVisible: .constant(true))
    }
}
