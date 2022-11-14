//
//  DurationDistanceStringView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct DurationDistanceStringView: View {
    
    let travelTime: Double
    let distanceInMeters: Double
    let isShortened: Bool
    let asStack: Bool

    var body: some View {
        if asStack {
            stackedDetails
        } else {
            lineDetails
        }
    }
    
    var lineDetails: some View {
        
        let time = Time().secondsToHoursMinutes(travelTime)
        let distanceString = Distance().distanceCompleteString(distanceInMeters, shortened: isShortened)

        let hours = time.hours == 0 ? "" : "\(time.hours)"
        let hr = isPlural(time.hours) ? "hrs" : "hr"
        let hoursString = "\(hours) \(hr)"
        
        let minutes = time.minutes == 0 ? "" : "\(time.minutes)"
        let min = isPlural(time.minutes) ? "mins" : "min"
        let minutesString =  "\(minutes) \(min)"
                
        return Text("\(hoursString) \(minutesString) (\(distanceString))")
    }
    
    var stackedDetails: some View {
        
        if travelTime == 0 {
            
            return AnyView(calculatingPlaceholder)
            
        } else {
            
            return AnyView(VStack(alignment: .leading) {
                durationStack
                distanceStack
            })
        }
    }
    
    var durationStack: some View {
        
        let time = Time().secondsToHoursMinutes(travelTime)

        let hr = isPlural(time.hours) ? "hrs" : "hr"
        let min = isPlural(time.minutes) ? "mins" : "min"
        
        return HStack(alignment: .bottom) {
            Text("\(time.hours)")
                .font(.title3)
            Text(time.hours == 0 ? "" : hr)
                .font(.subheadline)
            Text("\(time.minutes)")
                .font(.title3)
            Text(time.minutes == 0 ? "" : min)
                .font(.subheadline)
        }
    }
    
    var distanceStack: some View {
        let dst = Distance().distanceAndMetric(distanceInMeters, shortened: isShortened)
        let stringDistance = String(format: "%.0f", dst.dist)
         return HStack(alignment: .bottom) {
             Text(stringDistance)
                 .font(.title3)
             Text(dst.metric)
                 .font(.subheadline)
        }
    }
    
    var calculatingPlaceholder: some View {
        HStack {
            ProgressView()
                .tint(K.Colors.WeenyWitch.orange)
            Text("Calculating")
                .padding(.horizontal)
        }
    }
    
    func isPlural(_ int: Int) -> Bool {
        int > 1
    }
}

struct DurationDistanceStringView_Previews: PreviewProvider {
    static var previews: some View {
        DurationDistanceStringView(travelTime: 120,
                                   distanceInMeters: 111,
                                   isShortened: false,
                                   asStack: false)
    }
}
