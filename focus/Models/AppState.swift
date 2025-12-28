//
//  AppState.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import Combine

/// Manages app-level state and preferences
class AppState: ObservableObject {
    
    static let shared = AppState()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    /// Reset onboarding (for testing)
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

