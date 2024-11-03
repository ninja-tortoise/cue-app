//
//  AlertConfigView.swift
//  Exposure
//
//  Created by Toby on 1/11/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

struct GeneralConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]

    var body: some View {
        NavigationView {
            List {
                
                
                Text("You will receive random notifications that are supposed to simulate an exposure event. When you open the notification, you'll be taken into the app to record your distress level.")
                    .disabled(true)
                
                // FEARED OUTCOME
                Section {
                    TextField("Example: sudden death", text: $appState.fearedOutcome)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                } header: {
                    Text("Feared Outcome")
                } footer: {
                    Text("What are you afraid will happen? Try to keep it short and to the point.")
                }

                // REMINDER
                Section {
                    TextField("Example: Thinking back on your life, what are you proudest moments?", text: $appState.postAlertReminder, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .lineLimit(2...10)
                } header: {
                    Text("Post-exposure Message")
                } footer: {
                    Text("Do you have any messages you want to receive after the initial exposure?")
                }
                
                Section("Alerts") {
                    NavigationLink {
                        AlertConfigView()
                    } label: {
                        Text("Configure Alerts")
                    }
                }
                
            }
//            .navigationTitle("Configure Alerts")
        }
    }
}

#Preview {
    GeneralConfigView()
//        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
