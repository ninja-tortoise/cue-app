//
//  Item.swift
//  Exposure
//
//  Created by Toby on 3/10/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
