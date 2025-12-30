//
//  UsageAttempt.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import Foundation
import SwiftData

/// Represents an attempt to open a blocked app
@Model
final class UsageAttempt {
    var id: UUID
    var appName: String  // Name of the app that was attempted to open
    var timestamp: Date
    var wasBlocked: Bool  // true if blocked, false if override was used
    var overrideMethod: String?  // e.g., "challenge", "manual" (nil if wasBlocked = true)
    
    /// Initialize a new usage attempt
    init(appName: String, wasBlocked: Bool, overrideMethod: String? = nil) {
        self.id = UUID()
        self.appName = appName
        self.timestamp = Date()
        self.wasBlocked = wasBlocked
        self.overrideMethod = overrideMethod
    }
    
    /// Get formatted timestamp
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    /// Check if this attempt was today
    var isToday: Bool {
        Calendar.current.isDateInToday(timestamp)
    }
    
    /// Check if this attempt was this week
    var isThisWeek: Bool {
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return timestamp >= weekAgo
    }
}

