//
//  OnboardingModel.swift
//  Exposure
//
//  Created by Toby on 7/1/2025.
//

import Foundation
import SwiftUI

struct OnboardingData: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String = ""
    var headline: String
    var image: String
    var gradientColors: [Color]
}

let onboardingData: [OnboardingData] = [
    OnboardingData(
      title: "Welcome to Cue",
      subtitle: "Your companion for random exposure therapy",
      headline: "You will receive random notifications like these throughout your day, creating a more authentic environment for facing thoughts and building resilience.\n\nYou can change the text, time and frequency of these notifications in the Configure page.\n\nJust tap the notification to open the app and record your thoughts.",
      image: "alert",
      gradientColors: [Color(hex: "beb9e7"), Color(hex: "daa092")]
    ),
    
    OnboardingData(
      title: "Log Your Reaction",
      subtitle: "Monitor your progress",
      headline: "When you open the notification, you'll be taken into the app to record some state of mind levels and comments.\n\nYou can customise your feared outcome at any time from the Your Fear page.",
      image: "input_elements",
      gradientColors: [Color(hex: "beb9e7"), Color(hex: "daa092")]
    ),
    
    OnboardingData(
      title: "Track Your Journey",
      subtitle: "Securely and privately",
      headline: "You can then track your improvement over time and export detailed reports to share with your mental health provider from the History page.\n\nAlways consult your mental health provider about incorporating Cue into your treatment plan.",
      image: "SUDS_graph",
      gradientColors: [Color(hex: "beb9e7"), Color(hex: "daa092")]
    ),
]


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
