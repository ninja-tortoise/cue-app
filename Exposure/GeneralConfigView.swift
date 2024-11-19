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
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationView {
            List {
                
                Section {
                    Text("You can personalise your reports & logging pages by including your feared outcome. Post-exposure messages can provide helpful thoughts during exposure.")
                        .disabled(true)
                }
                
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
                    TextField("Example: Thinking back on your life, what are your proudest moments?", text: $appState.postAlertReminder, axis: .vertical)
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
                        }
                } header: {
                    Text("Post-exposure Message")
                } footer: {
                    Text("Do you have any messages you want to receive after the initial exposure? What will help lower your distress levels?")
                }
                
//                Section("Alerts") {
//                    NavigationLink {
//                        AlertConfigView()
//                    } label: {
//                        Text("Configure Alerts")
//                    }
//                }
                
            }
            .navigationTitle("Your Fear")
            .scrollDismissesKeyboard(.immediately)
            
        }
    }
}

#Preview {
    GeneralConfigView()
//        .modelContainer(for: ExposureItem.self, inMemory: true)
        .environmentObject(AppState())
}
