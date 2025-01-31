//
//  AlertConfigView.swift
//  Exposure
//
//  Created by Toby on 1/11/2024.
//

import SwiftUI
import TipKit
import SwiftData
import UserNotifications

struct GeneralConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]
    @FocusState private var isFocused: Bool
    
    let fearPageInitialTip = FearPageInitialTip()

    var body: some View {
        NavigationStack {
            List {
                
                TipView(fearPageInitialTip)
                    .padding(-10)
                    .tipBackground(.clear)
                
                // FEARED OUTCOME
                Section {
                    TextField("Example: Sudden death", text: $appState.fearedOutcome)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
//                        .onChange(of: appState.fearedOutcome) {
//                                fearPageInitialTip.invalidate(reason: .actionPerformed)
//                        }
                } header: {
                    Text("Feared Outcome")
                } footer: {
                    Text("What thought or outcome makes you anxious? Try to be specific but brief.")
                }
                
                // REMINDER
                Section {
                    TextField("Example: I've handled this before and I can handle it now!", text: $appState.postAlertReminder, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .lineLimit(2...10)
                        .focused($isFocused)
                        .keyboardType(.alphabet)
                        .submitLabel(.done)
                        .onSubmit {
                            isFocused = false
                        }
                        .onChange(of: appState.postAlertReminder) {
                            guard isFocused else { return }
                            guard appState.postAlertReminder.contains("\n") else { return }
                            isFocused = false
                            appState.postAlertReminder = appState.postAlertReminder.replacing("\n", with: "")
//                            fearPageInitialTip.invalidate(reason: .actionPerformed)
                        }
                } header: {
                    Text("Post-exposure Message")
                } footer: {
                    Text("Write a calming message to yourself. What would help you in moments of anxiety?")
                }
            }
            .navigationTitle("Your Fear")
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    init() {
        /// Load and configure the state of all the tips of the app
        try? Tips.configure()
    }
}

#Preview {
    GeneralConfigView()
//        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
