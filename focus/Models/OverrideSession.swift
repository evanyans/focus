//
//  OverrideSession.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import Foundation
import SwiftData

/// Represents a temporary override session (when user completes challenge)
@Model
final class OverrideSession {
    var id: UUID
    var startTime: Date
    var endTime: Date  // When the override expires
    var challengeType: String  // e.g., "math", "typing"
    var wasUsed: Bool  // Did user actually open blocked apps during override?
    
    /// Initialize a new override session
    init(durationMinutes: Int = 5, challengeType: String = "math") {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.challengeType = challengeType
        self.wasUsed = false
    }
    
    /// Check if this override is still active
    var isActive: Bool {
        return Date() < endTime
    }
    
    /// Get remaining time in seconds
    var remainingSeconds: TimeInterval {
        return max(0, endTime.timeIntervalSinceNow)
    }
    
    /// Get the duration in minutes (calculated from start and end time)
    var durationMinutes: Int {
        let duration = endTime.timeIntervalSince(startTime)
        return Int(duration / 60)
    }
    
    /// Mark as used (user opened a blocked app)
    func markAsUsed() {
        self.wasUsed = true
    }
}

