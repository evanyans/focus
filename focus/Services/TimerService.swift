//
//  TimerService.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation

/// Service responsible for managing countdown timer logic
class TimerService {
    private var timer: Timer?
    private var endTime: Date?
    
    /// Callback invoked every second with remaining time
    var onTick: ((TimeInterval) -> Void)?
    
    /// Callback invoked when timer completes
    var onComplete: (() -> Void)?
    
    /// Start a countdown timer
    /// - Parameter duration: Duration in seconds
    func start(duration: TimeInterval) {
        stop() // Stop any existing timer
        
        endTime = Date().addingTimeInterval(duration)
        
        // Fire immediately to update UI
        tick()
        
        // Schedule timer to fire every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    /// Stop the timer
    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil
    }
    
    /// Internal tick method called every second
    private func tick() {
        guard let endTime = endTime else {
            stop()
            return
        }
        
        let remaining = endTime.timeIntervalSinceNow
        
        if remaining <= 0 {
            // Timer completed
            onTick?(0)
            onComplete?()
            stop()
        } else {
            // Update remaining time
            onTick?(remaining)
        }
    }
    
    deinit {
        stop()
    }
}

