//
//  FieldType.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/9/22.
//

import Foundation


enum FieldType {
    
    case start, end, none
    
    var labelText: String {
        
        switch self {
            
        case .start:
            return "start:"
            
        case .end, .none:
            return "  end:"
        }
    }
}


