//
//  FocusSession.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import SwiftData

/// Represents a focus session with duration and timing information
@Model
final class FocusSession {
    var id: UUID
    var duration: TimeInterval  // Total duration in seconds (e.g., 1500 = 25 minutes)
    var startTime: Date
    var endTime: Date?  // Actual end time (nil if session still active)
    var isActive: Bool
    var wasCompleted: Bool  // true if session finished naturally, false if ended early
    
    /// Computed property to get the planned end time
    var plannedEndTime: Date {
        return startTime.addingTimeInterval(duration)
    }
    
    /// Computed property to check if session has expired
    var hasExpired: Bool {
        return Date() >= plannedEndTime
    }
    
    /// Actual duration completed (for sessions ended early)
    var actualDuration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return duration
    }
    
    /// Initialize a new focus session
    /// - Parameter duration: Duration in seconds (default: 1500 = 25 minutes)
    init(duration: TimeInterval = 1500) {
        self.id = UUID()
        self.duration = duration
        self.startTime = Date()
        self.endTime = nil
        self.isActive = true
        self.wasCompleted = false
    }
    
    /// Mark session as completed
    func complete(early: Bool = false) {
        self.endTime = Date()
        self.isActive = false
        self.wasCompleted = !early
    }
}

