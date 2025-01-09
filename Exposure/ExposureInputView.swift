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
    @State private var note: String = ""
    @State private var answer2: String = ""
    @State private var showingAlert = false
    
    func getAnxietyLevelForSUD(level: Int) -> String {
        if 0...10 ~= level {
            return "No Anxiety"
        } else if 10...30 ~= level {
            return "Low Anxiety"
        } else if 30...50 ~= level {
            return "Moderate Anxiety"
        } else if 50...70 ~= level {
            return "Significant Anxiety"
        } else if 70...90 ~= level {
            return "High Anxiety"
        } else if 90...100 ~= level {
            return "Extreme Anxiety"
        }
        
        return "No Anxiety"
    }
    
    var body: some View {
        NavigationView {
            Form {
                if !appState.isFollowUp {
                    Section() {
                        Text("How likely is it that the feared outcome \(appState.fearedOutcome != "" ? "(\(appState.fearedOutcome))" : "") will happen now?")
                        Picker("Likelihood", selection: $likelihood) {
                            Text("Nil").tag(0)
                            Text("Low").tag(25)
                            Text("Moderate").tag(50)
                            Text("High").tag(75)
                            Text("Certain").tag(100)
                        }
                    }
                    Section() {
                        Text("How severe would it be if the feared outcome \(appState.fearedOutcome != "" ? "(\(appState.fearedOutcome))" : "") happened now?")
                        Picker("Severity", selection: $severity) {
                            Text("Nil").tag(0)
                            Text("Low").tag(25)
                            Text("Moderate").tag(50)
                            Text("High").tag(75)
                            Text("Certain").tag(100)
                        }
                    }
                }
                
                Section() {
                    Text("Please record your current Subjective Units of Distress (SUDS) level.")
                    
                    VStack {
                        Slider(value: Binding(get: { Double(currentDistress) }, set: { currentDistress = Int($0) }),
                               in: 0...100,
                               step: 5,
                               minimumValueLabel: Text("0"),
                               maximumValueLabel: Text("100")
                        ) {
                            Text("Level of Distress")
                        } .padding(.vertical, 8)
                        
                        HStack {
                            Text("\(currentDistress)")
                                .bold()
                            Text("(\(getAnxietyLevelForSUD(level: currentDistress)))")
                        }
                    }
                    
                }
                
                Section() {
                    Text("Do you have any observations or notes to add to this entry?")
                    TextField("Enter your thoughts here", text: $note)
                }
                
                Button("Submit") {
                    let uuid = appState.currentExposureUUID
                    
                    // Find matching exposure alert
                    if let exposureItem = exposureItems.first(where: { $0.uuid.uuidString == uuid }) {
                        
                        // Save likelihood, severity & timestamp for initial data log
                        if exposureItem.isEmpty && !appState.isFollowUp {
                            exposureItem.isEmpty = false
                            exposureItem.likelihood = likelihood
                            exposureItem.severity = severity
                            exposureItem.timestamp = Date()
                        }
                        
                        // Save any notes made
                        exposureItem.notes.append(note)
                        
                        // Save distress level
                        exposureItem.distressDict["\(Int(Date().timeIntervalSince1970))"] = currentDistress
                        try? modelContext.save()
                        
                        // Schedule next follow up
                        scheduleFollowUps(exposureItem: exposureItem)
                        
                        // Show reminder if user has set, otherwise just close view
                        if appState.postAlertReminder != "" {
                            showingAlert = true
                        } else {
                            appState.isExposureInputViewPresented = false
                        }
                    }
                }
            }
            .navigationTitle("Exposure Log")
            
            
        }
        
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Post-Exposure Message"),
                message: Text(appState.postAlertReminder),
                dismissButton: .default(Text("Dismiss"), action: {
                    appState.isExposureInputViewPresented = false }))
        }
    }
    
    private func removeAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func scheduleFollowUps(exposureItem: ExposureItem) {
        
        removeAlerts()
        
        let category = UNNotificationCategory(
            identifier: "exposureInput",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
                
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let interval = appState.followUpInterval
        var smartStop = false
        
        if appState.smartCheckIn {
            let sortedTimes = exposureItem.distressDict.keys.sorted(by: <)
            if let startTime = sortedTimes.first, let lastTime = sortedTimes.last {
                let firstSUDS = exposureItem.distressDict[startTime] ?? -1
                let latestSUDS = exposureItem.distressDict[lastTime] ?? -1
                
                print(firstSUDS, latestSUDS, latestSUDS <= firstSUDS/2)
                
                if latestSUDS <= firstSUDS/2 {
                    smartStop = true
                }
            }
            
        }
            
        if !smartStop && exposureItem.distressDict.keys.count <= appState.numberOfFollowUps {
            
            let content = UNMutableNotificationContent()
            let cal = Calendar.current
            
            content.title = "Exposure Check In"
            content.subtitle = "How are you feeling?"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "exposureInput"
            content.userInfo = ["uuid": "\(appState.currentExposureUUID)",
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
