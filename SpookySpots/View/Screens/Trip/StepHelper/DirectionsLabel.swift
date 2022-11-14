//
//  DirectionsLabel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI
import AVFoundation


struct DirectionsLabel: View {

    let txt: String
    let geo: GeometryProxy
    
    @Binding var isShowingMore: Bool

    private let speechSynthesizer = AVSpeechSynthesizer()
    
    let weenyWitch = K.Colors.WeenyWitch.self

    var body: some View {
            Text(txt)
                .foregroundColor(weenyWitch.lightest)
                .frame(maxWidth: geo.size.width - 60)
                .padding()
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: isShowingMore ? "arrow.up" : "arrow.down")
                        .font(.headline)
                        .foregroundColor(weenyWitch.orange)
                        .padding()
                }
            
                .onAppear {
                    let speechUtterance = AVSpeechUtterance(string: txt)
                    speechSynthesizer.speak(speechUtterance)
                }
        
    }
    
}


struct DirectionsLabel_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            DirectionsLabel(txt: "Turn Left",
                            geo: geo,
                            isShowingMore: .constant(true))
        }
    }
}
