//
//  ContentView.swift
//  Exposure
//
//  Created by Toby on 3/10/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]
    @State private var daysBetweenAlerts = 2

    var body: some View {
        NavigationSplitView {
            
            List {
                Section("Configuration") {
                    Stepper("Alert every \(daysBetweenAlerts) day(s)", value: $daysBetweenAlerts, in: 0...14)
                    HStack {
                        Text("Follow up Interval")
                        Spacer(minLength: 25)
                        Picker("Follow up Interval", selection: $appState.followUpInterval) {
//                            Text("5s").tag(5)
                            Text("10s").tag(10)
                            Text("60s").tag(60)
                            Text("5m").tag(300)
                            Text("10m").tag(600)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Stepper("Follow up \(appState.numberOfFollowUps) times", value: $appState.numberOfFollowUps, in: 0...20)
                    
                    HStack {
                        if items.count > 0 {
                            Button("Save") {
                                scheduleAlerts()
                            }
                            .foregroundStyle(.blue)
                            .bold()
                        } else {
                            Button("Start") {
                                scheduleAlerts()
                            }
                            .foregroundStyle(.blue)
                            .bold()
                        }
                        
                    }
                }
            
                Section("Log History") {
                    ForEach(items.sorted(by: { $0.timestamp < $1.timestamp })) { item in
                        if !item.isEmpty {
                            NavigationLink {
                                ExposureItemDetail(exposureItem: item)
                            } label: {
                                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                            }
                        }
                    }.onDelete(perform: deleteLoggedItem)
                }
                
                Section("Upcoming") {
                    ForEach(items.sorted(by: { $0.timestamp < $1.timestamp })) { item in
                        if item.isEmpty {
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                                    Spacer()
                                    Text("Pending")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }.onDelete(perform: deleteUpcomingItem)
                }
                
                Button("Reset") {
                    removeAlerts()
                }.foregroundStyle(.red)
                
            }
            .navigationTitle("Exposure Alert")
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $appState.isExposureInputViewPresented) {
            ExposureInputView()
        }
//        .onAppear(perform: reloadData)
    }
    
    private func scheduleAlerts() {
        requestPermission()
        removeAlerts()
        
        let category = UNNotificationCategory(
            identifier: "exposureInput",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
                
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        for i in 0..<10 {
            
            let content = UNMutableNotificationContent()
            content.title = "Exposure Time"
            content.subtitle = "You're about to die! Log your reaction and thoughts"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "exposureInput"
            
            let uuid = UUID()
            content.userInfo = ["uuid": uuid.uuidString]
            
            let cal = Calendar.current
            
            let randomOffset = Int.random(in: -27000..<27000)
            var interval = daysBetweenAlerts * 24 * 60 * 60 * (i) // + 2
            var startDate = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            
            if i >= 0 {
                startDate.hour = 14
                startDate.minute = 30
                interval += randomOffset
            }
            
            if let startDate = cal.date(from: startDate), let fireDate = cal.date(byAdding: .second, value: interval, to: startDate) {
                
                let fireDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
                
                withAnimation {
                    let newItem = ExposureItem(uuid: uuid, at: fireDate)
                    modelContext.insert(newItem)
                    print("NEW EXPOSURE: \(uuid) | \(fireDate.formatted()) | \(i)")
                }
            }
        }
    }
    
    private func removeAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
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
    
    private func deleteLoggedItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let loggedItems = items.filter({!$0.isEmpty})
                modelContext.delete(loggedItems.sorted(by: { $0.timestamp < $1.timestamp })[index])
            }
        }
    }

    private func deleteUpcomingItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let upcomingItems = items.filter({$0.isEmpty})
                modelContext.delete(upcomingItems.sorted(by: { $0.timestamp < $1.timestamp })[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
