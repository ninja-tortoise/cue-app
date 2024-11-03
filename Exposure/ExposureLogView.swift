//
//  AlertConfigView.swift
//  Exposure
//
//  Created by Toby on 1/11/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ExposureLogView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]

    var body: some View {
        NavigationView {
            List {
                
                Section("Past logs") {
                    if items.filter({!$0.isEmpty}).count == 0 {
                        Text("No exposure logs completed yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items.filter({!$0.isEmpty}).sorted(by: { $0.timestamp < $1.timestamp })) { item in
                        NavigationLink {
                            ExposureItemDetail(exposureItem: item)
                        } label: {
                            Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        }
                    }.onDelete(perform: deleteLoggedItem)
                }
                
                if items.filter({!$0.isEmpty}).count > 0 {
                    Button("Export as PDF") {
                        exportPDF()
                    }.foregroundStyle(.blue)
                }
                
                Section("Upcoming Alerts") {
                    if items.filter({$0.isEmpty}).count == 0 {
                        Button("Tap to schedule future alerts") {
                            withAnimation {
                                scheduleAlerts()
                            }
                        }
                    } else {
                        ForEach(items.filter({$0.isEmpty}).sorted(by: { $0.timestamp < $1.timestamp })) { item in
                            HStack {
                                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("Pending")
                                    .foregroundStyle(.secondary)
                            }
                        }.onDelete(perform: deleteUpcomingItem)
                    }
                }
                
                if items.filter({$0.isEmpty}).count > 0 {
                    Button("Cancel All Upcoming Alerts") {
                        removeAlerts()
                    }.foregroundStyle(.red)
                }
                
            }
            .navigationTitle("History")
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
    
    private func exportPDF() {
        
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
    ExposureLogView()
//        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
