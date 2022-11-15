//
//  StepHelper.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct StepHelper: View {
    
    var geo: GeometryProxy
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @Binding var isShowingMoreSteps: Bool
    
    @ObservedObject var tripLogic = TripLogic.instance
    
    var body: some View {
        routeStepHelper(geo)
    }
    
    private func routeStepHelper(_ geo: GeometryProxy) -> some View {
        
        let maxFrameSize = geo.size.height / 2
        let fittedSize = CGFloat(tripLogic.currentTrip?.remainingSteps.count ?? 0) * 40
        let fittedIsSmallerThanMax = fittedSize < maxFrameSize
        let frameSize = fittedIsSmallerThanMax ? fittedSize : maxFrameSize
        
        return VStack {
            
            currentStep(geo)
            
            if isShowingMoreSteps {
                
                list
                    .frame(height: frameSize)
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(weenyWitch.black)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    private func currentStep(_ geo: GeometryProxy) -> some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
        
        let firstStepWithText = orderedSteps.first(where: { $0.instructions != "" })
        
        return Button {
            self.isShowingMoreSteps.toggle()
        } label: {
            DirectionsLabel(
                txt: firstStepWithText?.instructions ?? "",
                geo: geo,
                isShowingMore: $isShowingMoreSteps)
            
        }
        .padding()
        
        .onAppear {
            if let first = orderedSteps.first {
                if first.instructions == "" {
                    tripLogic.currentTrip?.remainingSteps.removeAll(where: { $0 == first })
                }
            }
        }
    }
    
    private var list: some View {
        let orderedSteps = tripLogic.currentTrip?
            .remainingSteps
            .sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) ?? []
       return List(orderedSteps,
                    id: \.self) { step in
            
            if step != orderedSteps.first {
                if step.instructions != "" {
                    Text(step.instructions ?? "")
                        .foregroundColor(weenyWitch.light)
                        .listRowBackground(Color.clear)
                }
            }
        }
                    .modifier(ClearListBackgroundMod())
                    .padding(.top, -35)
    }
}

struct StepHelper_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            StepHelper(geo: geo,
                       isShowingMoreSteps: .constant(true))
        }
    }
}
