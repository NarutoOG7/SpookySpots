//
//  PagedImageView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/26/22.
//

import SwiftUI

//MARK: - PagingView

struct PagingView<Content>: View where Content: View {

    @Binding var index: Int
    let maxIndex: Int
    let totalIndex: Int
    let content: () -> Content

    @State private var offset = CGFloat.zero
    @State private var dragging = false

    init(index: Binding<Int>, maxIndex: Int, totalIndex: Int, @ViewBuilder content: @escaping () -> Content) {
        self._index = index
        self.maxIndex = maxIndex
        self.totalIndex = totalIndex
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        self.content()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }
                .content.offset(x: self.offset(in: geometry), y: 0)
                .frame(width: geometry.size.width, alignment: .leading)
                .gesture(
                    DragGesture().onChanged { value in
                        self.dragging = true
                        self.offset = -CGFloat(self.index) * geometry.size.width + value.translation.width
                    }
                    .onEnded { value in
                        let predictedEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
                        let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
                        self.index = self.clampedIndex(from: predictedIndex)
                        withAnimation(.easeOut) {
                            self.dragging = false
                        }
                    }
                )
            }
            .clipped()

            PageControl(index: index, maxIndex: maxIndex, totalIndex: totalIndex)
        }
    }

    func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }

    func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, self.index - 1), self.index + 1)
        guard newIndex >= 0 else { return 0 }
        guard newIndex <= maxIndex else { return maxIndex }
        return newIndex
    }
}



//MARK: - PageControl

struct PageControl: View {
     var index: Int
     let maxIndex: Int
    let totalIndex: Int
    
    private var lowestIndex: Int = 0
    private var highestIndex: Int = 1
    
    var previousIndices: [Int] = []
    var nextIndices: [Int] = []
    
    
    init(index: Int, maxIndex: Int, totalIndex: Int) {
        self.index = index
        self.maxIndex = maxIndex
        self.totalIndex = totalIndex
        
        highestIndex = maxIndex
    }
    
     var body: some View {
         HStack {
             Spacer()
             
             HStack(spacing: 8) {
                 ForEach(0...(totalIndex), id: \.self) { index in
                     
                     if Range(lowestIndex...highestIndex).contains(index) {
                         let isEnd = index == lowestIndex || index == highestIndex
                             Circle()
                                 .fill(index == self.index ? Color.white : Color.gray)
                                 .frame(width: isEnd ? 5 : 8, height: isEnd ? 5 : 8)
                     }
                     
                    
                 }
             }
             .padding(15)
             
             Spacer()
         }

     }
}


//MARK: - For Preview
struct PagedImageView: View {
    @State var index = 0
    var images = ["bannack", "apple", "bannack", "apple"]

    var body: some View {
        PagingView(index: $index, maxIndex: images.count - 1, totalIndex: 3) {
            ForEach(self.images, id: \.self) { imageName in
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct PagedImageView_Previews: PreviewProvider {
    static var previews: some View {
        PagedImageView()
    }
}
