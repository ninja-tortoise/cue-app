//
//  Tips.swift
//  Exposure
//
//  Created by Toby on 7/1/2025.
//

import SwiftUI
import TipKit

struct FearPageInitialTip: Tip {
    var title: Text {
        Text("Personalise your exposure practice")
    }
    var message: Text? {
        Text("Enter your feared outcome here and create a supportive message to help you during exposure moments.")
    }
    var image: Image? {
        Image(systemName: "person.wave.2")
    }
}

struct HistoryPageInitialTip: Tip {
    var title: Text {
        Text("View your progress")
    }
    var message: Text? {
        Text("Here you can browse previous exposure results, see upcoming alerts, and export your results to PDF.")
    }
    var image: Image? {
        Image(systemName: "chart.line.text.clipboard")
    }
}

struct ConfigPageInitialTip: Tip {
    var title: Text {
        Text("Set some ground rules")
    }
    var message: Text? {
        Text("Configure the frequency, amount and time ranges of your exposure alerts here to work for you.")
    }
    var image: Image? {
        Image(systemName: "gearshape.2.fill")
    }
}
