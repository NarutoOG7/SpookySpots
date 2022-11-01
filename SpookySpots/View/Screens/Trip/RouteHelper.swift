//
//  RouteHelper.swift
//  SpookySpots
//
//  Created by Spencer Belton on 9/6/22.
//

import SwiftUI
import AVFoundation


struct RouteHelper: View {
    
    @EnvironmentObject var tripLogic: TripLogic
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                VStack {
                    VStack(alignment: .leading) {
                        
                        driveTime
                        distance
                        
                        
                        if tripLogic.alternates.indices.contains(0) {
                            ColorBar(position: 0, title: "1.", color: .green)
                        }
                        
                        if tripLogic.alternates.indices.contains(1) {
                            ColorBar(position: 1, title: "2.", color: .blue)
                        }
                        
                        if tripLogic.alternates.indices.contains(2) {
                            ColorBar(position: 2, title: "3.", color: .yellow)
                        }
                    }
                    moreRoutesButton
                    
                }
                .padding()
                .background(weenyWitch.lightest.cornerRadius(20))
            }
            .padding()
            .padding(.top, 100)
            Spacer()
            
        }
    }
    
    //MARK: - SubViews
    
    private var driveTime: some View {
        HStack {
            Image(systemName: "car.fill")
                .font(.caption)
            Text(tripLogic.getHighlightedRouteTravelTimeAsDigitalString() ?? "")
        }
        .padding(.bottom, 2)
    }
    
    private var distance: some View {
        HStack {
            Image(systemName: "fuelpump.fill")
                .font(.caption)
            Text(tripLogic.getDistanceStringFromRoute(tripLogic.currentRoute ?? Route(), shortened: true))
        }
    }
    
    //MARK: - Buttons
    
    private var moreRoutesButton: some View {
        Button(action: moreRoutesTapped) {
            if tripLogic.alternateRouteState == .selected && tripLogic.selectedAlternate != nil {
                Text("DONE")
                    .foregroundColor(weenyWitch.orange)
            } else if tripLogic.alternateRouteState == .showingAll {
                Text("cancel")
                    .foregroundColor(weenyWitch.orange)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(weenyWitch.orange)
            }
        }
        .padding(.top)
    }
    
    //MARK: - Methods
    
    private func moreRoutesTapped() {
        tripLogic.alternatesLogic()
    }
}

struct RouteHelper_Previews: PreviewProvider {
    static var previews: some View {
        RouteHelper()
    }
}


//MARK: - Color Bar

struct ColorBar: View {

    @EnvironmentObject var tripLogic: TripLogic

    var position: Int?
    var title: String?
    var color: Color
    
    var body: some View {
        HStack {
            Text(title ?? "")
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(width: 50, height: 12)
        }
        //        .padding(.vertical, 7)
        //        .padding(.horizontal, 12)
        .overlay(background.padding(-7))
        .onTapGesture(perform: onTapped)
    }

    //MARK: - Background
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 2)
            .fill(isSelected() ? .orange : .clear)
    }

    //MARK: - Methods

    private func isSelected() -> Bool {
        if let position = position {
            return tripLogic.positionIsSelected(position)
        }
        return false
    }

    private func onTapped() {
        if let position = position {
            tripLogic.selectAlternate(position)
        }
        tripLogic.alternateRouteState = .selected
    }
}


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

//MARK: - Total Trip Details String

struct DurationDistanceString: View {
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

struct Time {
    var hours: Int = 0
    var minutes: Int = 0
    
    func secondsToHoursMinutes(_ seconds: Double) -> Time {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return Time(hours: hours, minutes: minutes)
    }
    
    func formatTime(time: Double) -> String? {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.hour, .minute]
        return dateFormatter.string(from: time)
    }
    
}

struct Distance {
    func distanceAndMetric(_ meters: Double, shortened: Bool) -> (dist: Double, metric: String) {
        let locale = Locale.current
        let usesMetric = locale.usesMetricSystem
        
        var distance: Double = 0
        let unitSystem = usesMetric ? "meters" : "miles"
        let shortenedUnitSystem  = usesMetric ? "m" : "mi"

            let miles = meters * 0.000621371
            let dist = usesMetric ? meters : miles
            distance += dist
        
        let unitString = shortened ? shortenedUnitSystem : unitSystem


        return (distance, unitString)
    }
    
    func distanceCompleteString(_ meters: Double, shortened: Bool) -> String {
        let dst = distanceAndMetric(meters, shortened: shortened)
        let str = String(format: "%.0f \(dst.metric)", dst.dist)
        return str
    }
    
}
