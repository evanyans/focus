//
//  StreakService.swift
//  focus
//
//  Created on 2025-12-29.
//

import Foundation
import SwiftData

/// Service for calculating and tracking streaks (days without using overrides)
class StreakService {
    
    /// Calculate current streak (consecutive days without overrides)
    /// Streak breaks if user uses an override on any day
    static func calculateStreak(overrideSessions: [OverrideSession]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // If no override sessions exist yet, return 0 (new user)
        if overrideSessions.isEmpty {
            return 0
        }
        
        // Group overrides by day where they were actually used
        var overridesByDay: Set<Date> = Set()
        var earliestDate: Date? = nil
        
        for override in overrideSessions {
            let day = calendar.startOfDay(for: override.startTime)
            
            // Track earliest date to limit streak counting
            if earliestDate == nil || day < earliestDate! {
                earliestDate = day
            }
            
            // Only count as breaking streak if override was used
            if override.wasUsed {
                overridesByDay.insert(day)
            }
        }
        
        // Check if user used override today - streak should be 0
        if overridesByDay.contains(today) {
            return 0
        }
        
        var streak = 0
        var currentDay = today
        
        // Count consecutive days without overrides, but only back to earliest session
        let limitDate = earliestDate ?? today
        
        while currentDay >= limitDate && !overridesByDay.contains(currentDay) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = previousDay
            
            // Safety limit
            if streak >= 365 {
                break
            }
        }
        
        return streak
    }
    
    /// Get streak message based on current streak
    static func streakMessage(for streak: Int) -> String {
        switch streak {
        case 0:
            return "Start fresh today! 🚀"
        case 1:
            return "Great start! Keep going 💪"
        case 2...6:
            return "Building momentum! 🔥"
        case 7...13:
            return "One week strong! 🎯"
        case 14...29:
            return "Two weeks! You're unstoppable! ⚡"
        case 30...59:
            return "A full month! Legendary! 👑"
        default:
            return "Focus master! \(streak) days! 🏆"
        }
    }
    
    /// Check if user used an override today
    static func usedOverrideToday(overrideSessions: [OverrideSession]) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return overrideSessions.contains { override in
            calendar.isDate(override.startTime, inSameDayAs: today) && override.wasUsed
        }
    }
}

