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
    
    // Notification identifier for focus session completion
    private let sessionCompleteIdentifier = "focus.session.complete"
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification permission from the user
    /// - Returns: True if permission granted, false otherwise
    @MainActor
    func requestPermission() async -> Bool {
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
    func checkPermission() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Session Notifications
    
    /// Schedule a notification for when the focus session completes
    /// - Parameter duration: Duration in seconds until notification fires
    func scheduleSessionCompleteNotification(duration: TimeInterval) async {
        // Cancel any existing notifications first
        await cancelSessionNotifications()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎉"
        content.body = "Great work! You've completed your focus session."
        content.sound = .default
        content.badge = 1
        
        // Create trigger (fire after duration)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: sessionCompleteIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await notificationCenter.add(request)
            print("✅ Notification scheduled for \(Int(duration)) seconds")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }
    
    /// Cancel all pending focus session notifications
    func cancelSessionNotifications() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [sessionCompleteIdentifier])
        print("🔕 Cancelled pending notifications")
    }
    
    /// Clear delivered notifications from notification center
    func clearDeliveredNotifications() {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [sessionCompleteIdentifier])
    }
}

