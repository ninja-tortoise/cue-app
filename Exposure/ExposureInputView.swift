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
                    Section() {
                        Text("How likely is it that the feared outcome will happen now?")
                        Picker("Likelihood", selection: $likelihood) {
                            Text("Nil").tag(0)
                            Text("Low").tag(25)
                            Text("Moderate").tag(50)
                            Text("High").tag(75)
                            Text("Certain").tag(100)
                        }
                    }
                    Section() {
                        Text("How severe would it be if the feared outcome happened now?")
                        Picker("Severity", selection: $severity) {
                            Text("Nil").tag(0)
                            Text("Low").tag(25)
                            Text("Moderate").tag(50)
                            Text("High").tag(75)
                            Text("Certain").tag(100)
                        }
                    }
                }
                
                Section(header: Text("Level of Distress")) {
                    Text("Please record your current Subjective Units of Distress (SUDS) level.\n\n0 = no anxiety\n50 = significant anxiety\n100 = extreme anxiety\n\nCurrent Distress: \(currentDistress)")
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
