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
                if !appState.isFollowUp {
                    Section(header: Text("Preparation")) {
                        Text("How likely is it that you will die right now?\n\n\(likelihood)%")
                        Slider(value: Binding(get: { Double(likelihood) }, set: { likelihood = Int($0) }), in: 0...100, step: 1) {
                            Text("Likelihood")
                        }
                        
                        Text("How severe would it be if you died?\n\n\(severity)%")
                        Slider(value: Binding(get: { Double(severity) }, set: { severity = Int($0) }), in: 0...100, step: 1) {
                            Text("Severity")
                        }
                    }
                }
                
                Section(header: Text("Level of Distress")) {
                    Text("Please record your current Subjective Units of Distress (SUDS) level.\n\nCurrent Distress: \(currentDistress)")
                    Slider(value: Binding(get: { Double(currentDistress) }, set: { currentDistress = Int($0) }), in: 0...100, step: 5) {
                        Text("Level of Distress")
                    }
                }
                
                Button("Submit") {
                    if let uuid = appState.currentExposureUUID,
                       let exposureItem = exposureItems.first(where: { $0.uuid == uuid }) {
                        if exposureItem.isEmpty && !appState.isFollowUp {
                            exposureItem.isEmpty = false
                            exposureItem.likelihood = likelihood
                            exposureItem.severity = severity
                        }
                        
                        exposureItem.distressDict["\(Int(Date().timeIntervalSince1970))"] = currentDistress
                        try? modelContext.save()
                        appState.isExposureInputViewPresented = false
                        
                        scheduleFollowUps(exposureItem: exposureItem)
                    }
                }
            }
            .navigationTitle("Exposure Log")
        }
    }
    
    private func scheduleFollowUps(exposureItem: ExposureItem) {
        
        let category = UNNotificationCategory(
            identifier: "exposureInput",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
                
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let interval = appState.followUpInterval
        
        if exposureItem.distressDict.keys.count < appState.numberOfFollowUps {
            
            let content = UNMutableNotificationContent()
            let cal = Calendar.current
            
            content.title = "Exposure Follow Up"
            content.subtitle = "How are you feeling?"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "exposureInput"
            content.userInfo = ["uuid": appState.currentExposureUUID?.uuidString ?? "nil",
                                "isFollowUp": true]
            
            if let fireDate = cal.date(byAdding: .second, value: interval, to: Date()) {
                
                let fireDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}

#Preview {
    ExposureInputView()
        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
