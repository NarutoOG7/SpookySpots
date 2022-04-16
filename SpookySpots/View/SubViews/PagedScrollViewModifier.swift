//
//  PagedScrollViewModifier.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/30/22.
//

import SwiftUI

struct PagedScrollViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().isPagingEnabled = true
            } .onDisappear {
                UIScrollView.appearance().isPagingEnabled = false
            }
    }
}


extension ScrollView {
    func pagedScrollView() -> some View {
        modifier(PagedScrollViewModifier())
    }
}