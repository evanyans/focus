//
//  ScreenTimeService.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Service responsible for Screen Time API integration
@MainActor
class ScreenTimeService: ObservableObject {
    
    static let shared = ScreenTimeService()
    
    private let authorizationCenter = AuthorizationCenter.shared
    private let managedSettingsStore = ManagedSettingsStore()
    
    @Published var isAuthorized: Bool = false
    
    private init() {
        // Check initial authorization status
        updateAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Request Screen Time authorization from the user
    /// This shows a system dialog explaining Screen Time access
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            updateAuthorizationStatus()
            print("✅ Screen Time authorization granted")
        } catch {
            // Check if this is the expected Simulator error
            let nsError = error as NSError
            if nsError.domain == "NSCocoaErrorDomain" && nsError.code == 4099 {
                print("ℹ️ Screen Time API not available (likely running in Simulator)")
            } else {
                print("❌ Screen Time authorization denied: \(error)")
            }
            throw error
        }
    }
    
    /// Check if currently authorized
    func checkAuthorization() -> Bool {
        return authorizationCenter.authorizationStatus == .approved
    }
    
    /// Update the published authorization status
    private func updateAuthorizationStatus() {
        isAuthorized = checkAuthorization()
    }
    
    // MARK: - App Blocking
    
    /// Apply blocking restrictions for selected apps
    /// - Parameter selection: FamilyActivitySelection containing apps to block
    func applyBlocking(for selection: FamilyActivitySelection) {
        guard isAuthorized else {
            print("ℹ️ Skipping app blocking (Screen Time not authorized)")
            return
        }
        
        // Block selected applications
        managedSettingsStore.shield.applications = selection.applicationTokens
        
        // Block categories if any selected
        if !selection.categoryTokens.isEmpty {
            managedSettingsStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selection.categoryTokens
            )
        }
        
        print("🔒 Applied blocking for \(selection.applicationTokens.count) apps")
    }
    
    /// Remove all blocking restrictions
    func removeBlocking() {
        guard isAuthorized else {
            print("ℹ️ Skipping removal (Screen Time not authorized)")
            return
        }
        
        // Clear all shields
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomainCategories = nil
        
        print("🔓 Removed all blocking")
    }
    
    /// Clear all managed settings (complete reset)
    func clearAllRestrictions() {
        managedSettingsStore.clearAllSettings()
        print("🧹 Cleared all Screen Time restrictions")
    }
}

