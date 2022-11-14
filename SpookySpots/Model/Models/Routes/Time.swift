//
//  Time.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import Foundation


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
