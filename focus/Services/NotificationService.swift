//
//  NotificationService.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import UserNotifications

/// Service responsible for managing local notifications
class NotificationService {
    
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Notification identifiers
    private let blockingStartIdentifier = "focus.blocking.start"
    private let blockingEndIdentifier = "focus.blocking.end"
    private let overrideExpiringIdentifier = "focus.override.expiring"
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification permission from the user
    /// - Returns: True if permission granted, false otherwise
    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Check current notification authorization status
    /// - Returns: True if authorized, false otherwise
    func checkAuthorization() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule notifications for blocking start/end based on schedule
    func scheduleBlockingNotifications(for schedule: BlockingSchedule) async {
        // Cancel existing schedule notifications
        await cancelBlockingNotifications()
        
        // Schedule "Blocking Starting" notification
        let startContent = UNMutableNotificationContent()
        startContent.title = "Blocking Active"
        startContent.body = "\(schedule.name) has started. Selected apps are now blocked."
        startContent.sound = .default
        
        // Schedule "Blocking Ending" notification
        let endContent = UNMutableNotificationContent()
        endContent.title = "Blocking Ended"
        endContent.body = "\(schedule.name) has ended. Apps are now accessible."
        endContent.sound = .default
        
        // Create calendar triggers for recurring notifications
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: schedule.startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: schedule.endTime)
        
        // Schedule for each day of the week
        for weekday in schedule.daysOfWeek {
            var startDateComponents = startComponents
            startDateComponents.weekday = weekday
            
            var endDateComponents = endComponents
            endDateComponents.weekday = weekday
            
            let startTrigger = UNCalendarNotificationTrigger(dateMatching: startDateComponents, repeats: true)
            let endTrigger = UNCalendarNotificationTrigger(dateMatching: endDateComponents, repeats: true)
            
            let startRequest = UNNotificationRequest(
                identifier: "\(blockingStartIdentifier).\(weekday)",
                content: startContent,
                trigger: startTrigger
            )
            
            let endRequest = UNNotificationRequest(
                identifier: "\(blockingEndIdentifier).\(weekday)",
                content: endContent,
                trigger: endTrigger
            )
            
            do {
                try await notificationCenter.add(startRequest)
                try await notificationCenter.add(endRequest)
            } catch {
                print("❌ Error scheduling notification: \(error)")
            }
        }
        
        print("✅ Scheduled blocking notifications for \(schedule.name)")
    }
    
    /// Schedule notification when override is about to expire
    func scheduleOverrideExpiringNotification(expiresIn seconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        content.title = "Override Expiring Soon"
        content.body = "Your temporary access will end in 1 minute."
        content.sound = .default
        
        // Trigger 1 minute before expiration
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(0, seconds - 60), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: overrideExpiringIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled override expiring notification")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }
    
    /// Cancel all blocking notifications
    func cancelBlockingNotifications() async {
        let identifiers = (1...7).flatMap { weekday in
            ["\(blockingStartIdentifier).\(weekday)", "\(blockingEndIdentifier).\(weekday)"]
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 Cancelled blocking notifications")
    }
    
    /// Cancel override notifications
    func cancelOverrideNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [overrideExpiringIdentifier])
    }
    
    /// Clear all delivered notifications
    func clearDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}

