//
//  FocusSessionViewModel.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import Combine

/// ViewModel managing focus session state and business logic
@MainActor
class FocusSessionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current active session, nil when no session is running
    @Published var currentSession: FocusSession?
    
    /// Remaining time in seconds for the current session
    @Published var remainingTime: TimeInterval = 0
    
    /// Computed property to check if a session is currently active
    var isSessionActive: Bool {
        return currentSession?.isActive == true
    }
    
    // MARK: - Private Properties
    
    private var timerService: TimerService?
    private let notificationService = NotificationService.shared
    private let screenTimeService = ScreenTimeService.shared
    private let appSettings = AppSettings.shared
    
    // MARK: - Public Methods
    
    /// Start a new focus session
    /// - Parameter duration: Duration in seconds (default: 1500 = 25 minutes)
    func startSession(duration: TimeInterval = 1500) {
        // Create new session
        let session = FocusSession(duration: duration)
        currentSession = session
        remainingTime = duration
        
        // Initialize timer service
        let timer = TimerService()
        timerService = timer
        
        // Set up timer callbacks
        timer.onTick = { [weak self] remaining in
            Task { @MainActor in
                self?.remainingTime = remaining
            }
        }
        
        timer.onComplete = { [weak self] in
            Task { @MainActor in
                self?.handleSessionComplete()
            }
        }
        
        // Start the timer
        timer.start(duration: duration)
        
        // Schedule completion notification
        Task {
            await notificationService.scheduleSessionCompleteNotification(duration: duration)
        }
        
        // Apply app blocking if user has selected apps
        if appSettings.hasSelectedApps {
            screenTimeService.applyBlocking(for: appSettings.selectedApps)
        }
    }
    
    /// End the current session manually
    func endSession() {
        timerService?.stop()
        currentSession = nil
        remainingTime = 0
        timerService = nil
        
        // Cancel pending notification since user ended session early
        Task {
            await notificationService.cancelSessionNotifications()
        }
        
        // Remove app blocking
        screenTimeService.removeBlocking()
    }
    
    // MARK: - Private Methods
    
    /// Handle session completion
    private func handleSessionComplete() {
        currentSession = nil
        remainingTime = 0
        timerService = nil
        
        // Remove app blocking when session completes
        screenTimeService.removeBlocking()
        
        // Notification is already scheduled and will fire automatically
        // TODO: Log session in Phase 4
    }
    
    /// Format time interval as MM:SS
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

