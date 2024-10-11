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
    @State private var notifications: [UNNotificationRequest] = []

    var body: some View {
        NavigationSplitView {
            
            VStack(spacing: 20) {
                Stepper("Alert every \(daysBetweenAlerts) day(s)", value: $daysBetweenAlerts, in: 0...14)
                .padding(30)
                
                Button("Schedule Notifications") {
                    scheduleAlerts()
                }
                
                Button("Remove All Notifications") {
                    removeAlerts()
                }
            }
            .navigationTitle("Exposure Alert")
            
            
            List {
                ForEach(items.sorted(by: { $0.timestamp < $1.timestamp })) { item in
                    NavigationLink {
                        VStack {
                            Text("Notification Date: \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                            Text("Is empty: \(item.isEmpty)")
//                            Text("Answer 1: \(item.answer1)")
//                            Text("Answer 2: \(item.answer2)")
                            Text("Likelihood: \(item.likelihood)")
                            Text("Severity: \(item.severity)")
                            Text("distressOverTime: \(item.distressOverTime)")
                        }
                    } label: {
                        if item.isEmpty {
                            HStack {
                                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("Pending")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        }
                    }
                }
                .onDelete(perform: deleteItems)
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
            }
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
            var interval = daysBetweenAlerts * 24 * 60 * 60 * (i) + 10
            var startDate = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            
            if i > 0 {
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
                    print("NEW EXPOSURE: \(uuid) | \(fireDate) | \(i)")
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

//    private func addItem() {
//        withAnimation {
//            let newItem = ExposureItem(timestamp: Date())
//            modelContext.insert(newItem)
//            print("added")
//        }
//    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ExposureItem.self, inMemory: true)
}
