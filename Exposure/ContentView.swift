//
//  ContentView.swift
//  Exposure
//
//  Created by Toby on 3/10/2024.
//

import TipKit
import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]
    @AppStorage("isOnboarding") var isOnboarding: Bool = true

    var body: some View {
        TabView {
            
            Tab("Your Fear", systemImage: "pencil.line") {
                GeneralConfigView()
            }
            
            Tab("History", systemImage: "chart.line.text.clipboard") {
                ExposureLogView()
            }
            
            Tab("Configure", systemImage: "gearshape.2.fill") {
                AlertConfigView()
            }
            
        }
        .sheet(isPresented: $appState.isExposureInputViewPresented) {
            ExposureInputView()
        }
        .sheet(isPresented: $isOnboarding) {
            WelcomeView()
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

actor BackgroundImporter {
    @MainActor
    var modelContainer: ModelContainer

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let items = ExposureItem.previews

        for i in 0..<items.count {
            self.modelContainer.mainContext.insert(items[i])
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ExposureItem.self, configurations: config)
    let importer = BackgroundImporter(modelContainer: container)

    ContentView()
        .modelContainer(container)
        .environmentObject(AppState())
}
