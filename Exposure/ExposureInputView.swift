//
//  InputView.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//
import SwiftUI
import SwiftData
import UserNotifications

struct ExposureInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exposureItems: [ExposureItem]
    @EnvironmentObject var appState: AppState
    
    @State private var likelihood: Int = 0
    @State private var severity: Int = 0
    @State private var currentDistress: Int = 0
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preparation")) {
                    Text("How likely is it that the feared outcome (i.e. death) will happen:\n\n\(likelihood)%")
                    Slider(value: Binding(get: { Double(likelihood) }, set: { likelihood = Int($0) }), in: 0...100, step: 1) {
                        Text("Likelihood")
                    }
                    
                    Text("How severe would it be if this happened:\n\n\(severity)%")
                    Slider(value: Binding(get: { Double(severity) }, set: { severity = Int($0) }), in: 0...100, step: 1) {
                        Text("Severity")
                    }
                }
                
                Section(header: Text("Distress")) {
                    Text("After exposing yourself to the feared situation, record your Subjective Units of Distress (SUDS) every few minutes.\n\nCurrent Level of Distress: \(currentDistress)")
                    Slider(value: Binding(get: { Double(currentDistress) }, set: { currentDistress = Int($0) }), in: 0...100, step: 5) {
                        Text("Level of Distress")
                    }
                }
                
                Button("Submit") {
                    if let uuid = appState.currentExposureUUID,
                       let exposureItem = exposureItems.first(where: { $0.uuid == uuid }) {
                        exposureItem.isEmpty = false
                        exposureItem.likelihood = likelihood
                        exposureItem.severity = severity
                        exposureItem.distressOverTime = currentDistress
                        try? modelContext.save()
                        appState.isExposureInputViewPresented = false
                    }
                }
            }
            .navigationTitle("Exposure Log")
        }
    }
}

#Preview {
    ExposureInputView()
        .modelContainer(for: ExposureItem.self, inMemory: true)
}
