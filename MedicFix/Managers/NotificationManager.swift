//
//  NotificationManager.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotifications(for medication: Medication) {
        // Remove existing notifications for this medication
        removeNotifications(for: medication)
        
        guard medication.isActive else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take \(medication.name) \(medication.dosage)"
        content.sound = .default
        content.userInfo = ["medicationId": medication.id.uuidString]
        
        // Schedule for each day of the week
        for day in medication.daysOfWeek {
            let components = createDateComponents(forWeekday: day, andTime: medication.timeOfDay)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "\(medication.id.uuidString)_\(day)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func removeNotifications(for medication: Medication) {
        let identifiers = medication.daysOfWeek.map { "\(medication.id.uuidString)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func rescheduleAllNotifications(for medications: [Medication]) {
        for medication in medications {
            scheduleNotifications(for: medication)
        }
    }
    
    private func createDateComponents(forWeekday weekday: Int, andTime time: Date) -> DateComponents {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.weekday = weekday
        
        return dateComponents
    }
}
