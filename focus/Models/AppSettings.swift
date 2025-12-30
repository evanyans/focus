//
//  AppSettings.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import Combine
import FamilyControls

/// Manages persistent storage of user's app blocking preferences
class AppSettings: ObservableObject {
    
    static let shared = AppSettings()
    
    /// Selected apps and categories to block during focus sessions
    @Published var selectedApps: FamilyActivitySelection {
        didSet {
            saveSelection()
        }
    }
    
    /// Default session duration in seconds
    @Published var defaultDuration: TimeInterval {
        didSet {
            UserDefaults.standard.set(defaultDuration, forKey: durationKey)
        }
    }
    
    /// Key for UserDefaults storage
    private let selectionKey = "focus.app.selection"
    private let durationKey = "focus.default.duration"
    
    private init() {
        // Load saved selection or create empty one
        if let data = UserDefaults.standard.data(forKey: selectionKey),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.selectedApps = decoded
        } else {
            self.selectedApps = FamilyActivitySelection()
        }
        
        // Load default duration (default to 25 minutes = 1500 seconds)
        let savedDuration = UserDefaults.standard.double(forKey: durationKey)
        self.defaultDuration = savedDuration > 0 ? savedDuration : 1500
    }
    
    /// Check if user has selected any apps
    var hasSelectedApps: Bool {
        return !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }
    
    /// Save the current selection to UserDefaults
    private func saveSelection() {
        if let encoded = try? JSONEncoder().encode(selectedApps) {
            UserDefaults.standard.set(encoded, forKey: selectionKey)
            print("💾 Saved app selection: \(selectedApps.applicationTokens.count) apps")
        }
    }
    
    /// Clear all selected apps
    func clearSelection() {
        selectedApps = FamilyActivitySelection()
    }
}

