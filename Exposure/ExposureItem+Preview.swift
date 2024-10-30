//
//  ExposureItem+Preview.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//

import Foundation
import SwiftData

extension ExposureItem {
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
        return expItem
    }
}
