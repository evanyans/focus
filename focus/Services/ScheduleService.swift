//
//  ScheduleService.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import Foundation
import SwiftData
import Combine

/// Manages blocking schedules and determines when blocking should be active
@MainActor
class ScheduleService: ObservableObject {
    static let shared = ScheduleService()
    
    @Published var isBlockingActive: Bool = false
    @Published var activeSchedule: BlockingSchedule?
    @Published var nextScheduleChange: Date?
    
    private var modelContext: ModelContext?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Start monitoring schedule changes
        startMonitoring()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        checkSchedules()
    }
    
    /// Start monitoring for schedule changes
    private func startMonitoring() {
        // Check every minute for schedule changes
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkSchedules()
            }
        }
        // Initial check
        checkSchedules()
    }
    
    /// Check all schedules and update blocking state
    func checkSchedules() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<BlockingSchedule>(
            predicate: #Predicate<BlockingSchedule> { $0.isEnabled == true },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            let schedules = try context.fetch(descriptor)
            
            // Find if any schedule is currently active
            let activeSchedules = schedules.filter { $0.isActiveNow() }
            
            if let firstActive = activeSchedules.first {
                isBlockingActive = true
                activeSchedule = firstActive
                print("🔒 Blocking active: \(firstActive.name)")
                
                // Apply blocking with selected apps
                let selectedApps = AppSettings.shared.selectedApps
                ScreenTimeService.shared.applyBlocking(for: selectedApps)
            } else {
                isBlockingActive = false
                activeSchedule = nil
                print("🔓 Blocking inactive")
                
                // Remove blocking
                ScreenTimeService.shared.removeBlocking()
            }
            
            // Calculate next schedule change
            calculateNextScheduleChange(schedules: schedules)
            
        } catch {
            print("Failed to fetch schedules: \(error)")
        }
    }
    
    /// Calculate when the next schedule change will occur
    private func calculateNextScheduleChange(schedules: [BlockingSchedule]) {
        let calendar = Calendar.current
        let now = Date()
        var nextChange: Date?
        
        for schedule in schedules {
            let todayWeekday = calendar.component(.weekday, from: now)
            
            if schedule.daysOfWeek.contains(todayWeekday) {
                // Schedule applies today
                let startComponents = calendar.dateComponents([.hour, .minute], from: schedule.startTime)
                let endComponents = calendar.dateComponents([.hour, .minute], from: schedule.endTime)
                
                if let startDate = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                                  minute: startComponents.minute ?? 0,
                                                  second: 0,
                                                  of: now),
                   let endDate = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                                minute: endComponents.minute ?? 0,
                                                second: 0,
                                                of: now) {
                    
                    // Check if start time is in the future
                    if startDate > now {
                        if nextChange == nil || startDate < nextChange! {
                            nextChange = startDate
                        }
                    }
                    
                    // Check if end time is in the future
                    if endDate > now {
                        if nextChange == nil || endDate < nextChange! {
                            nextChange = endDate
                        }
                    }
                }
            }
        }
        
        self.nextScheduleChange = nextChange
    }
    
    /// Get all schedules
    func getAllSchedules() -> [BlockingSchedule] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<BlockingSchedule>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch schedules: \(error)")
            return []
        }
    }
    
    /// Add a new schedule
    func addSchedule(_ schedule: BlockingSchedule) {
        guard let context = modelContext else { return }
        context.insert(schedule)
        
        do {
            try context.save()
            print("✅ Schedule saved: \(schedule.name)")
            checkSchedules()
        } catch {
            print("Failed to save schedule: \(error)")
        }
    }
    
    /// Delete a schedule
    func deleteSchedule(_ schedule: BlockingSchedule) {
        guard let context = modelContext else { return }
        context.delete(schedule)
        
        do {
            try context.save()
            print("🗑️ Schedule deleted: \(schedule.name)")
            checkSchedules()
        } catch {
            print("Failed to delete schedule: \(error)")
        }
    }
    
    /// Toggle schedule enabled state
    func toggleSchedule(_ schedule: BlockingSchedule) {
        schedule.isEnabled.toggle()
        
        guard let context = modelContext else { return }
        do {
            try context.save()
            print("🔄 Schedule toggled: \(schedule.name) - \(schedule.isEnabled ? "enabled" : "disabled")")
            checkSchedules()
        } catch {
            print("Failed to toggle schedule: \(error)")
        }
    }
    
    /// Check if there's an active override session
    func hasActiveOverride() -> Bool {
        guard let context = modelContext else { return false }
        
        let descriptor = FetchDescriptor<OverrideSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            return sessions.first?.isActive ?? false
        } catch {
            return false
        }
    }
    
    /// Get active override session
    func getActiveOverride() -> OverrideSession? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<OverrideSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            return sessions.first(where: { $0.isActive })
        } catch {
            return nil
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

