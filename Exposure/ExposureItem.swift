//
//  Item.swift
//  Exposure
//
//  Created by Toby on 3/10/2024.
//

import Foundation
import SwiftData

@Model
final class ExposureItem {
    var uuid: UUID
    var timestamp: Date
    
    var isEmpty: Bool = true
    var answer1: String = ""
    var answer2: String = ""
    var likelihood: Int = 0
    var severity: Int = 0
    var distressOverTime: Int = 0
    
    init(uuid: UUID, at time: Date) {
        self.uuid = uuid
        self.timestamp = time
    }
}
