//
//  ExposureItem+Preview.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//

import Foundation
import SwiftData
import SwiftUICore

extension ExposureItem {
    
    static var previews: [ExposureItem] {
        
        let count = 5
        let dayInterval = 1
        let alertStartHr = 7
        let alertEndHr = 22
        var expItems: [ExposureItem] = []
        
        for dayOffset in 1 ... count {
            
            let cal = Calendar.current
            let randSecondsRange = (alertEndHr - alertStartHr) * 60 * 60
            let randomOffset = Int.random(in: -(randSecondsRange/2)..<(randSecondsRange/2))
            var interval = -dayInterval * 24 * 60 * 60 * (dayOffset)
            var startDate = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            
            let hourOffset = Double(alertEndHr - alertStartHr)/2.0 + Double(alertStartHr)
            startDate.hour = Int(floor(hourOffset))
            startDate.minute = Int(hourOffset.truncatingRemainder(dividingBy: 1) * 60)
            interval += randomOffset
            
            if let alertDate = cal.date(from: startDate), let fireDate = cal.date(byAdding: .second, value: interval, to: alertDate) {
                
                let timestamp = Int(fireDate.timeIntervalSince1970)
                let expItem = ExposureItem(uuid: UUID(), at: fireDate)
                expItem.isEmpty = false
                expItem.severity = Int.random(in: 0 ... 100)
                expItem.likelihood = Int.random(in: 0 ... 100)
                expItem.distressDict = [
                    "\(timestamp)":                               Int.random(in: 80 ... 100),
                    "\(timestamp + 1*Int.random(in: 60 ... 70))": Int.random(in: 60 ... 90),
                    "\(timestamp + 2*Int.random(in: 60 ... 70))": Int.random(in: 40 ... 80),
                    "\(timestamp + 3*Int.random(in: 60 ... 70))": Int.random(in: 30 ... 70),
                    "\(timestamp + 4*Int.random(in: 60 ... 70))": Int.random(in: 20 ... 60),
                    "\(timestamp + 5*Int.random(in: 60 ... 70))": Int.random(in:  0 ... 40),
                ]
                let randomNotes = ["", "", "Something is going on", "", "", "I feel better now", "Lorem ipsum", "This is fantastic", "This is a much longer note that might be typed in if someone wants to go into a lot of detail.", "", "I watched a movie last night", "", "I went to the gym", "I went to the grocery store"]
                expItem.notes = Array(Set(randomNotes).prefix(6))
                
                expItems.append(expItem)
            }
        }
        
        return expItems
    }
    
    static var preview: ExposureItem {
        let expItem = ExposureItem(uuid: UUID(), at: Date())
        expItem.isEmpty = false
        expItem.severity = 5
        expItem.likelihood = 15
        expItem.distressDict = [
            "1728643185": 95,
            "1728643485": 55,
            "1728643785": 95,
            "1728644085": 85,
            "1728644385": 45,
            "1728644685": 15,
//            "1728643245": 80,
//            "1728643305": 60,
//            "1728643365": 35,
//            "1728643425": 5,
//            "1728643825": 25,
        ]
        expItem.notes = ["", "", "something is going on", "", "", "i feel better now"]
        return expItem
    }
}
