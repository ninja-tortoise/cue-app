//
//  ExposureApp.swift
//  Exposure
//
//  Created by Toby on 3/10/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ExposureApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExposureItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear(perform: setupNotificationObserver)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupNotificationObserver() {
            NotificationCenter.default.addObserver(
                forName: Notification.Name("OpenExposureInputView"),
                object: nil,
                queue: .main
            ) { notification in
                if let uuid = notification.userInfo?["uuid"] as? UUID {
                    appState.currentExposureUUID = uuid
                    appState.isExposureInputViewPresented = true
                }
            }
        }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.notification.request.content.categoryIdentifier == "exposureInput" {
            if let uuidString = response.notification.request.content.userInfo["uuid"] as? String,
               let uuid = UUID(uuidString: uuidString) {
                NotificationCenter.default.post(name: Notification.Name("OpenExposureInputView"), object: nil, userInfo: ["uuid": uuid])
            }
        }
        completionHandler()
    }
}

class AppState: ObservableObject {
    @Published var isExposureInputViewPresented = false
    @Published var currentExposureUUID: UUID?
}
