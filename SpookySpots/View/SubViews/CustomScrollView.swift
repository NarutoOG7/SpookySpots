//
//  CustomScrollView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct HorizontalSnap: ViewModifier {
    
    @State private var scrollOffset: CGFloat
    @State private var dragOffset: CGFloat
    
    var items: Int
    var itemWidth: CGFloat
    var itemSpacing: CGFloat
    
    init(items: Int, itemWidth: CGFloat, itemSpacing: CGFloat) {
        self.items = items
        self.itemWidth = itemWidth
        self.itemSpacing = itemSpacing
        
        let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
        let screenWidth = UIScreen.main.bounds.width
        
        let initailOffset = (contentWidth / 2) - (screenWidth / 2) + ((screenWidth - itemWidth) / 2)
        
        self._scrollOffset = State(initialValue: initailOffset)
        self._dragOffset = State(initialValue: 0)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: scrollOffset + dragOffset, y: 0)
            .gesture(DragGesture()
                        .onChanged({ event in
                            dragOffset = event.translation.width
                        })
                        .onEnded({ event in
                            scrollOffset += event.translation.width
                            dragOffset = 0
                            
                            let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
                            let screenWidth = UIScreen.main.bounds.width
                            
                            let center = scrollOffset + (screenWidth / 2) + (contentWidth / 2)
                            
                            var index = (center - (screenWidth / 2)) / (itemWidth + itemSpacing)
                            
                            if index.remainder(dividingBy: 1) > 0.5 {
                                index += 1
                            } else {
                                index = CGFloat(Int(index))
                            }
                            index = min(index, CGFloat(items) - 1)
                            index = max(index, 0)
                            
                            let newOffset = (index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2) + (screenWidth / 2) - ((screenWidth - itemWidth) / 2) + itemSpacing)
                                
                                withAnimation {
                                    scrollOffset = newOffset
                                }
                        })
                     
            )
    }
}

struct HorizontalSnapScrollView: View {
     
    var items: [Location]
    
    
    @ObservedObject var locationStore = LocationStore.instance
    
    var body: some View {
        HStack {
            ForEach(items) { location in
                DefaultLocationCell(location: location)
            }
        }.modifier(HorizontalSnap(items: items.count, itemWidth: UIScreen.main.bounds.width - 60, itemSpacing: 20))
    }
}

struct HorizontalSnapScrollView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalSnapScrollView(items: [Location.example, Location.example, Location.example])
    }
}
              
