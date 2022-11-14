//
//  Distance.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import Foundation

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
