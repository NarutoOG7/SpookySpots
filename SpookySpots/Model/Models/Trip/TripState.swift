//
//  TripState.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import Foundation

enum TripState: String {
    
    case building
    case navigating
    case paused
    case finished
    
    func buttonTitle() -> String {
        switch self {
            
        case .building:
            return "HUNT"
            
        case .paused, .finished:
            return "Resume"
            
        case .navigating:
            return "END"
            
        }
    }

}
