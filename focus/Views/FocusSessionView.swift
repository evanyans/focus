//
//  FocusSessionView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI
import FamilyControls

/// Main view for the focus app - shows start button or active session
struct FocusSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = FocusSessionViewModel()
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var appSettings = AppSettings.shared
    @ObservedObject private var screenTimeService = ScreenTimeService.shared
    
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showReauthorizationAlert = false
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                // Show onboarding first
                OnboardingView(onComplete: {
                    appState.hasCompletedOnboarding = true
                })
            } else {
                // Show main app
                mainContent
            }
        }
        .onAppear {
            // Inject modelContext into ViewModel
            viewModel.modelContext = modelContext
            
            // Check Screen Time authorization status on launch
            checkAuthorizationStatus()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Re-check authorization when app comes to foreground
            if newPhase == .active {
                checkAuthorizationStatus()
            }
        }
        .alert("Permission Lost", isPresented: $showReauthorizationAlert) {
            Button("Re-authorize") {
                Task {
                    try? await screenTimeService.requestAuthorization()
                }
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text("Screen Time access was revoked. This can happen if you force-quit the app while selecting apps. Please re-authorize to enable app blocking.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkAuthorizationStatus() {
        let wasAuthorized = screenTimeService.isAuthorized
        let isAuthorized = screenTimeService.checkAuthorization()
        
        print("📱 Authorization check - Was: \(wasAuthorized), Is: \(isAuthorized)")
        
        // If we had authorization before but lost it, show alert
        if wasAuthorized && !isAuthorized && appSettings.hasSelectedApps {
            showReauthorizationAlert = true
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                if viewModel.isSessionActive {
                    // Show active session view
                    ActiveSessionView(viewModel: viewModel)
                } else {
                    // Show start button
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // App title/logo area
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 80))
                                .foregroundStyle(.blue)
                            
                            Text("Focus")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        // Start button
                        Button(action: {
                            viewModel.startSession()
                        }) {
                            Text("Start Focus Session")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.isSessionActive {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showHistory = true
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showHistory) {
                SessionHistoryView()
            }
        }
    }
}

#Preview {
    FocusSessionView()
}

