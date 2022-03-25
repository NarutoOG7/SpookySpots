//
//  ExploreByListVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase

class ExploreByListVM: ObservableObject {
    static let instance = ExploreByListVM()
    @Published var isShowingMap = false
    
}
