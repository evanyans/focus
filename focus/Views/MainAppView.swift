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
    @ObservedObject private var appState = AppState.shared
    
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
    }
}

#Preview {
    MainAppView()
        .modelContainer(for: [BlockingSchedule.self, UsageAttempt.self, OverrideSession.self], inMemory: true)
}

