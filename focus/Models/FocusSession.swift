//
//  FocusSession.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation

/// Represents a focus session with duration and timing information
struct FocusSession {
    let duration: TimeInterval  // Total duration in seconds (e.g., 1500 = 25 minutes)
    let startTime: Date
    var isActive: Bool
    
    /// Computed property to get the expected end time
    var endTime: Date {
        return startTime.addingTimeInterval(duration)
    }
    
    /// Computed property to check if session has expired
    var hasExpired: Bool {
        return Date() >= endTime
    }
    
    /// Initialize a new focus session
    /// - Parameter duration: Duration in seconds (default: 1500 = 25 minutes)
    init(duration: TimeInterval = 1500) {
        self.duration = duration
        self.startTime = Date()
        self.isActive = true
    }
}

