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
    @StateObject private var viewModel = FocusSessionViewModel()
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var appSettings = AppSettings.shared
    
    @State private var showSettings = false
    
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
        }
    }
}

#Preview {
    FocusSessionView()
}

