//
//  MedicFixApp.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
@main
struct MedicFixApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
        // Request notification permissions on app launch
        NotificationManager.shared.requestPermission { granted in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

// Add this AppDelegate to properly handle notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set the notification delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Allow notifications to show while app is in foreground
        completionHandler([.banner, .sound])
    }
}
