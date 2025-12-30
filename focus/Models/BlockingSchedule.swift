//
//  BlockingSchedule.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import Foundation
import SwiftData

/// Represents a recurring schedule for when apps should be blocked
@Model
final class BlockingSchedule {
    var id: UUID
    var name: String  // e.g., "Work Hours", "Sleep Time"
    var startTime: Date  // Time of day (only hour/minute matter)
    var endTime: Date    // Time of day (only hour/minute matter)
    var daysOfWeek: [Int]  // 1=Sunday, 2=Monday, ..., 7=Saturday (matches Calendar.Component.weekday)
    var isEnabled: Bool
    var createdAt: Date
    
    /// Initialize a new blocking schedule
    init(name: String, startTime: Date, endTime: Date, daysOfWeek: [Int], isEnabled: Bool = true) {
        self.id = UUID()
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.createdAt = Date()
    }
    
    /// Check if this schedule is currently active
    func isActiveNow() -> Bool {
        guard isEnabled else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        
        // Check if today is included in the schedule
        guard daysOfWeek.contains(currentWeekday) else { return false }
        
        // Extract time components from schedule
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // Get current time components
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        
        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endHour = endComponents.hour,
              let endMinute = endComponents.minute,
              let nowHour = nowComponents.hour,
              let nowMinute = nowComponents.minute else {
            return false
        }
        
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let nowMinutes = nowHour * 60 + nowMinute
        
        // Handle schedules that cross midnight
        if endMinutes < startMinutes {
            return nowMinutes >= startMinutes || nowMinutes < endMinutes
        } else {
            return nowMinutes >= startMinutes && nowMinutes < endMinutes
        }
    }
    
    /// Get formatted time range string (e.g., "9:00 AM - 5:00 PM")
    func timeRangeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    /// Get formatted days string (e.g., "Mon, Tue, Wed")
    func daysString() -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return daysOfWeek.sorted().map { dayNames[$0 - 1] }.joined(separator: ", ")
    }
}

