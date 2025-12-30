//
//  MainAppView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData

/// Main app view that handles onboarding and home screen
struct MainAppView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var screenTimeService = ScreenTimeService.shared
    @ObservedObject private var appSettings = AppSettings.shared
    
    @State private var showReauthorizationAlert = false
    
    // Key for UserDefaults
    private let wasAuthorizedKey = "wasScreenTimeAuthorized"
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                NewOnboardingView(onComplete: {
                    appState.hasCompletedOnboarding = true
                })
            } else {
                HomeView()
            }
        }
        .onAppear {
            // Save authorization state to persistent storage
            saveAuthorizationState()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Check authorization when app comes to foreground
            if newPhase == .active {
                // Force refresh authorization status from system
                let _ = screenTimeService.checkAuthorization()
                
                // Then check if we need to show alert
                checkAuthorizationStatus()
            }
        }
        .onChange(of: screenTimeService.isAuthorized) { oldValue, newValue in
            // Update saved state whenever authorization changes
            if newValue {
                UserDefaults.standard.set(true, forKey: wasAuthorizedKey)
                print("✅ Screen Time authorization tracked")
            }
        }
        .alert("Screen Time Access Lost", isPresented: $showReauthorizationAlert) {
            Button("Re-authorize Now") {
                Task {
                    try? await screenTimeService.requestAuthorization()
                    if screenTimeService.isAuthorized {
                        UserDefaults.standard.set(true, forKey: wasAuthorizedKey)
                    }
                }
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text("Screen Time access was revoked. This can happen when you force-quit the app. Your selected apps are saved. Please re-authorize to continue blocking.")
        }
    }
    
    private func saveAuthorizationState() {
        // Save current authorization state if authorized
        if screenTimeService.isAuthorized {
            UserDefaults.standard.set(true, forKey: wasAuthorizedKey)
        }
    }
    
    private func checkAuthorizationStatus() {
        // Check if user was authorized before (persisted)
        let wasAuthorizedBefore = UserDefaults.standard.bool(forKey: wasAuthorizedKey)
        let isCurrentlyAuthorized = screenTimeService.isAuthorized
        
        print("🔍 Authorization check - Was: \(wasAuthorizedBefore), Now: \(isCurrentlyAuthorized)")
        
        // Only show alert if:
        // 1. User has completed onboarding
        // 2. User had apps selected
        // 3. Authorization was previously granted but is now lost
        if appState.hasCompletedOnboarding && 
           appSettings.hasSelectedApps && 
           wasAuthorizedBefore && 
           !isCurrentlyAuthorized {
            print("⚠️ Authorization lost - showing alert")
            showReauthorizationAlert = true
        }
    }
}

#Preview {
    MainAppView()
        .modelContainer(for: [BlockingSchedule.self, UsageAttempt.self, OverrideSession.self], inMemory: true)
}

