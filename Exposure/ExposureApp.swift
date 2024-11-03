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
    @Environment(\.modelContext) private var modelContext
    
    @Published var isExposureInputViewPresented = false
    @Published var currentExposureUUID: UUID?
    @Published var isFollowUp: Bool = false
    @Published var numberOfFollowUps: Int = 4
    @Published var followUpInterval: Int = 60
    
    @Published var fearedOutcome: String = ""
    @Published var postAlertReminder: String = ""
    
    @Published var customAlertText: Bool = false
    @Published var customAlertTitle: String = "You're about to die!"
    @Published var customAlertDesc: String = "What are your final thoughts?"
    @Published var defaultAlertTitle: String = "Exposure Alert"
    @Published var defaultAlertDesc: String = "Open to log your reaction"
    @Published var alertStartHr: Int = 7
    @Published var alertEndHr: Int = 22
    @Published var daysBetweenAlerts = 2
    
    func scheduleAlerts() -> [ExposureItem] {
        
        let category = UNNotificationCategory(
            identifier: "exposureInput",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
                
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        var newItems: [ExposureItem] = []
        
        for i in 0..<10 {
            
            let content = UNMutableNotificationContent()
            content.title = customAlertText ? customAlertTitle : defaultAlertTitle
            content.subtitle = customAlertText ? customAlertDesc : defaultAlertDesc
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "exposureInput"
            
            let uuid = UUID()
            content.userInfo = ["uuid": uuid.uuidString]
            
            let cal = Calendar.current
            
            let randSecondsRange = (alertEndHr - alertStartHr) * 60 * 60
            let randomOffset = Int.random(in: -(randSecondsRange/2)..<(randSecondsRange/2))
            var interval = daysBetweenAlerts * 24 * 60 * 60 * (i)
            var startDate = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            
            if i >= 0 {
                let hourOffset = Double(alertEndHr - alertStartHr)/2.0 + Double(alertStartHr)
                startDate.hour = Int(floor(hourOffset))
                startDate.minute = Int(hourOffset.truncatingRemainder(dividingBy: 1) * 60)
                interval += randomOffset
            }
            
            if let startDate = cal.date(from: startDate), let fireDate = cal.date(byAdding: .second, value: interval, to: startDate) {
                
                let fireDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                  
                UNUserNotificationCenter.current().add(request)
                
                let newItem = ExposureItem(uuid: uuid, at: fireDate)
                newItems.append(newItem)
                print("NEW EXPOSURE: \(uuid) | \(fireDate.formatted()) | \(i)")
            }
        }
        
        return newItems
    }
}
