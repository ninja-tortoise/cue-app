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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

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
                    appState.isFollowUp = notification.userInfo?["isFollowUp"] as? Bool ?? false
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            // Here we actually handle the notification
            print("Notification received with identifier \(notification.request.identifier)")
            // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
            completionHandler([.banner, .sound])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.notification.request.content.categoryIdentifier == "exposureInput" {
            if let uuidString = response.notification.request.content.userInfo["uuid"] as? String,
               let uuid = UUID(uuidString: uuidString) {
                
                if let secondsSinceOG = response.notification.request.content.userInfo["isFollowUp"] as? Bool {
                    NotificationCenter.default.post(name: Notification.Name("OpenExposureInputView"), object: nil, userInfo: ["uuid": uuid, "isFollowUp": secondsSinceOG])
                } else {
                    NotificationCenter.default.post(name: Notification.Name("OpenExposureInputView"), object: nil, userInfo: ["uuid": uuid])
                }
            }
        }
        completionHandler()
    }
}

class AppState: ObservableObject {
    @Published var isExposureInputViewPresented = false
    @Published var currentExposureUUID: UUID?
    @Published var isFollowUp: Bool = false
    @Published var numberOfFollowUps: Int = 5
    @Published var followUpInterval: Int = 60
}
