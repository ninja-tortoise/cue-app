//
//  AlertConfigView.swift
//  Exposure
//
//  Created by Toby on 1/11/2024.
//

import TipKit
import SwiftUI
import SwiftData
import UserNotifications

struct AlertConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]
    
    let configInitialTip = ConfigPageInitialTip()

    var body: some View {
        NavigationView {
            Form {
                
                TipView(configInitialTip)
                    .padding(-10)
                    .tipBackground(.clear)
                
                // MARK: NOTIFICATION PREVIEW
                Section("Alert Preview") {
                    HStack {
                        Image(.icon)
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.vertical, 8)
                        VStack {
                            Text("\(appState.customAlertText ? appState.customAlertTitle : appState.defaultAlertTitle)\n\(appState.customAlertText ? appState.customAlertDesc : appState.defaultAlertDesc)")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .lineLimit(2)
                        }.padding(.leading, 8)
                    }
                }.listRowBackground(
                    LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .top, endPoint: .bottom)
                ).disabled(true)
                
                // MARK: ALERT TIMES
                Section {
                     
                    withAnimation {
                        Toggle("Customise message", isOn: $appState.customAlertText)
                            .onChange(of: appState.customAlertText) {
                                scheduleAlerts()
                            }
                    }
                    
                    if appState.customAlertText {
                        TextField("Alert Title", text: $appState.customAlertTitle)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .bold()
                            .disabled(!appState.customAlertText)
                            .foregroundStyle(appState.customAlertText ? .primary : .secondary)
                            .onAppear { UITextField.appearance().clearButtonMode = .always }
                            .onChange(of: appState.customAlertTitle) {
                                scheduleAlerts()
                            }
                        
                        TextField("Alert Description", text: $appState.customAlertDesc)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .lineLimit(1)
                            .bold()
                            .disabled(!appState.customAlertText)
                            .foregroundStyle(appState.customAlertText ? .primary : .secondary)
                            .onAppear { UITextField.appearance().clearButtonMode = .always }
                            .onChange(of: appState.customAlertDesc) {
                                scheduleAlerts()
                            }
                    }
                    
                    Picker("Only send after", selection: $appState.alertStartHr) {
                        ForEach(0..<24, id: \.self) {
                            let hour = $0
                            if hour != appState.alertEndHr {
                                if hour > 12 {
                                    Text("\(hour - 12):00\(hour >= 12 ? "pm" : "am")").tag($0)
                                } else {
                                    Text("\(hour == 0 ? 12 : hour):00\(hour >= 12 ? "pm" : "am")").tag($0)
                                }
                            }
                        }
                    }.onChange(of: appState.alertStartHr) {
                        scheduleAlerts()
                    }
                    
                    Picker("Only send before", selection: $appState.alertEndHr) {
                        ForEach(0..<24, id: \.self) {
                            let hour = $0
                            if hour != appState.alertStartHr {
                                if hour > 12 {
                                    Text("\(hour - 12):00\(hour >= 12 ? "pm" : "am")").tag($0)
                                } else {
                                    Text("\(hour == 0 ? 12 : hour):00\(hour >= 12 ? "pm" : "am")").tag($0)
                                }
                            }
                        }
                    }.onChange(of: appState.alertEndHr) {
                        scheduleAlerts()
                    }
                    
                    let frequencyPerDayString: String = appState.daysBetweenAlerts >= 1 ? "once" : "\(Int(floor(1/appState.daysBetweenAlerts))) times"
                    let frequencyDaysString: String = appState.daysBetweenAlerts > 1 ? "\(Int(appState.daysBetweenAlerts)) days" : "day"
                    
                    Stepper("Send \(frequencyPerDayString) every \(frequencyDaysString)",
                            value: $appState.freqIndex, in: 0...appState.alertFrequencies.count-1)
                    .onChange(of: appState.freqIndex) {
                        if appState.freqIndex < appState.alertFrequencies.count {
                            appState.daysBetweenAlerts = appState.alertFrequencies[appState.freqIndex]
                            scheduleAlerts()
                        }
                    }
                    
                } header: {
                    Text("Alert Settings")
                } footer: {
                    Text("This alert will randomly appear during the specified hours, simulating the feared outcome.")
                }
                
                // MARK: CHECK INS
                Section {
                    HStack {
                        Text("Check In after")
                        Spacer(minLength: 25)
                        Picker("Check In after", selection: $appState.followUpInterval) {
                            Text("30s").tag(30)
                            Text("1m").tag(60)
                            Text("5m").tag(300)
                            Text("10m").tag(600)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if !appState.smartCheckIn {
                        Stepper("Check In \(appState.numberOfFollowUps) times", value: $appState.numberOfFollowUps, in: 0...20)
                    }
                    
                    HStack {
                        VStack {
                            HStack {
                                Text("Smart Check In")
                                Spacer()
                            }
                            HStack {
                                Text("Stops checking in once SUDS falls below half of initial level.")
                                    .font(.caption2)
                                Spacer()
                            }
                        }
                        withAnimation {
                            Toggle("", isOn: $appState.smartCheckIn)
                                .labelsHidden()
                        }
                    }
                } header: {
                    Text("Checking In")
                } footer: {
                    Text("Check In alerts ask you to re-evaluate your distress level after exposure. This is tracked over time and displayed for review.")
                }
                
                // MARK: App About
                // TODO: Enable about page
//                Section {
//                    NavigationLink {
//                        AboutView()
//                    } label: {
//                        Text("About Cue")
//                    }
//                }
            }
            .navigationTitle("Configure Alerts")
        }
    }
    
    private func scheduleAlerts() {
        requestPermission()
        removeAlerts()
        
        let newItems = appState.scheduleAlerts()
        for item in newItems {
            modelContext.insert(item)
        }
    }
    
    private func removeAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        print("Removed all upcoming notifications")
        
        withAnimation {
            for currItem in items {
                if currItem.isEmpty {
                    modelContext.delete(currItem)
                }
            }
            
            do {
                try modelContext.save()
            } catch {
                print("uh oh")
            }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success , error in
            if success {
                print("lets go")
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AlertConfigView()
//        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
