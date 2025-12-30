//
//  OnboardingView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI
import FamilyControls

/// Onboarding view that guides users through permission setup
struct OnboardingView: View {
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @ObservedObject var appSettings = AppSettings.shared
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var showAppSelection = false
    @State private var hasRequestedScreenTime = false
    @State private var hasRequestedNotifications = false
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Paper background
                PaperTheme.background
                    .ignoresSafeArea()
                
                // Subtle paper texture
                PaperTheme.textureOverlay
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blendMode(.multiply)
                
                VStack(spacing: 0) {
                // Progress indicators
                HStack(spacing: 8) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue ? PaperTheme.accentBlue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content based on current step
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        stepView(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                VStack(spacing: 12) {
                    // Primary action button - paper style
                    Button(action: handlePrimaryAction) {
                        Text(primaryButtonTitle)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PaperTheme.buttonPrimary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(PaperTheme.border, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 3)
                    }
                    
                    // Secondary actions
                    HStack(spacing: 20) {
                        // Back button
                        if currentStep != .welcome {
                            Button(action: {
                                withAnimation {
                                    currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .welcome
                                }
                            }) {
                                Text("Back")
                                    .font(.subheadline)
                                    .foregroundColor(PaperTheme.accentBlue)
                            }
                        }
                        
                        // Skip button for optional steps
                        if currentStep == .notifications || currentStep == .screenTime {
                            Button(action: {
                                withAnimation {
                                    if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                                        currentStep = nextStep
                                    }
                                }
                            }) {
                                Text("Skip for Now")
                                    .font(.subheadline)
                                    .foregroundColor(PaperTheme.textTertiary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light) // Needed for status bar to show dark text on light background
        .sheet(isPresented: $showAppSelection) {
            AppSelectionView()
        }
    }
    
    // MARK: - Step Views
    
    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                switch step {
                case .welcome:
                    welcomeView
                case .notifications:
                    notificationsView
                case .screenTime:
                    screenTimeView
                case .selectApps:
                    selectAppsView
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
    
    // Welcome screen
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundStyle(PaperTheme.accentBlue)
            
            Text("Welcome to Focus")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(PaperTheme.textPrimary)
            
            Text("Block distracting apps and stay focused on what matters")
                .font(.body)
                .foregroundStyle(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "timer", title: "Timed Sessions", description: "Set focus periods of 15-60 minutes")
                FeatureRow(icon: "lock.shield", title: "App Blocking", description: "Block selected apps during focus time")
                FeatureRow(icon: "bell.badge", title: "Notifications", description: "Get notified when sessions complete")
            }
            .padding(.top, 20)
        }
    }
    
    // Notifications permission screen
    private var notificationsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(PaperTheme.accentGreen)
            
            Text("Enable Notifications")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(PaperTheme.textPrimary)
            
            Text("Get notified when your focus sessions are complete")
                .font(.body)
                .foregroundStyle(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                InstructionStep(number: 1, text: "Tap 'Enable Notifications' below")
                InstructionStep(number: 2, text: "iOS will show a permission dialog")
                InstructionStep(number: 3, text: "Tap 'Allow' to enable notifications")
            }
            .padding(.top, 20)
            
            if hasRequestedNotifications {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PaperTheme.accentGreen)
                    Text("Notification permission requested")
                        .font(.subheadline)
                        .foregroundStyle(PaperTheme.textPrimary)
                }
                .padding()
                .background(PaperTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(PaperTheme.border, lineWidth: 1)
                )
            }
        }
    }
    
    // Screen Time permission screen
    private var screenTimeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(PaperTheme.accentOrange)
            
            Text("Allow Screen Time Access")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(PaperTheme.textPrimary)
            
            Text("Required to block apps during focus sessions")
                .font(.body)
                .foregroundStyle(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            // What will happen
            VStack(alignment: .leading, spacing: 16) {
                Text("What happens next:")
                    .font(.headline)
                    .foregroundStyle(PaperTheme.textPrimary)
                
                VStack(spacing: 12) {
                    InstructionStep(number: 1, text: "Tap 'Request Permission' below")
                    InstructionStep(number: 2, text: "iOS will show: \"Focus would like to access Screen Time\"")
                    InstructionStep(number: 3, text: "Tap 'Continue' to allow app blocking")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(PaperTheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PaperTheme.border, lineWidth: 1)
            )
            
            // Visual example
            VStack(spacing: 12) {
                Text("You'll see a popup like this:")
                    .font(.caption)
                    .foregroundStyle(PaperTheme.textSecondary)
                
                // Mock dialog
                VStack(spacing: 16) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 40))
                        .foregroundStyle(PaperTheme.accentOrange)
                    
                    Text("\"Focus\" Would Like to Access Screen Time")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(PaperTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("This allows the app to block selected apps during focus sessions.")
                        .font(.caption)
                        .foregroundStyle(PaperTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 12) {
                        Text("Don't Allow")
                            .font(.caption)
                            .foregroundStyle(PaperTheme.accentRed)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PaperTheme.background)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(PaperTheme.border, lineWidth: 1)
                            )
                        
                        Text("Continue")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PaperTheme.accentBlue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(PaperTheme.background)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                            .stroke(PaperTheme.border, lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            // Status indicator
            if hasRequestedScreenTime {
                if screenTimeService.isAuthorized {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(PaperTheme.accentGreen)
                        Text("Permission granted! ✓")
                            .font(.subheadline)
                            .foregroundStyle(PaperTheme.textPrimary)
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(PaperTheme.border, lineWidth: 1)
                    )
                } else {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(PaperTheme.accentOrange)
                            Text("Permission not granted")
                                .font(.subheadline)
                                .foregroundStyle(PaperTheme.textPrimary)
                        }
                        Text("You can skip for now and try again later in Settings")
                            .font(.caption)
                            .foregroundStyle(PaperTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(PaperTheme.border, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // App selection screen
    private var selectAppsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 80))
                .foregroundStyle(PaperTheme.accentBlue)
            
            Text("Select Apps to Block")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(PaperTheme.textPrimary)
            
            Text("Choose which apps distract you the most")
                .font(.body)
                .foregroundStyle(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                InstructionStep(number: 1, text: "Tap 'Choose Apps' below")
                InstructionStep(number: 2, text: "Select apps you want to block")
                InstructionStep(number: 3, text: "Tap 'Done' when finished")
            }
            .padding(.top, 20)
            
            if appSettings.hasSelectedApps {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(PaperTheme.accentGreen)
                        Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                            .font(.subheadline)
                            .foregroundStyle(PaperTheme.textPrimary)
                    }
                    
                    Button(action: {
                        showAppSelection = true
                    }) {
                        Text("Edit Selection")
                            .font(.caption)
                            .foregroundColor(PaperTheme.accentBlue)
                    }
                }
                .padding()
                .background(PaperTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(PaperTheme.border, lineWidth: 1)
                )
            } else if !screenTimeService.isAuthorized {
                VStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(PaperTheme.accentBlue)
                    Text("Screen Time access required to select apps")
                        .font(.caption)
                        .foregroundStyle(PaperTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    Text("You can set this up later in Settings")
                        .font(.caption)
                        .foregroundStyle(PaperTheme.textSecondary)
                }
                .padding()
                .background(PaperTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(PaperTheme.border, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var primaryButtonTitle: String {
        switch currentStep {
        case .welcome:
            return "Get Started"
        case .notifications:
            return hasRequestedNotifications ? "Continue" : "Allow Notifications"
        case .screenTime:
            if screenTimeService.isAuthorized {
                return "Continue"
            } else if hasRequestedScreenTime {
                return "Continue Anyway"
            } else {
                return "Allow Screen Time"
            }
        case .selectApps:
            if appSettings.hasSelectedApps {
                return "Start Focusing"
            } else if screenTimeService.isAuthorized {
                return "Choose Apps"
            } else {
                return "Complete Setup"
            }
        }
    }
    
    private var canProceed: Bool {
        return true // Always allow proceeding through all steps
    }
    
    // MARK: - Actions
    
    private func handlePrimaryAction() {
        switch currentStep {
        case .welcome:
            withAnimation {
                currentStep = .notifications
            }
            
        case .notifications:
            if !hasRequestedNotifications {
                Task {
                    _ = await NotificationService.shared.requestPermission()
                    await MainActor.run {
                        hasRequestedNotifications = true
                    }
                }
            } else {
                withAnimation {
                    currentStep = .screenTime
                }
            }
            
        case .screenTime:
            if !hasRequestedScreenTime {
                Task {
                    do {
                        try await screenTimeService.requestAuthorization()
                        await MainActor.run {
                            hasRequestedScreenTime = true
                        }
                    } catch {
                        // Handle error (Screen Time API might not be available)
                        print("Screen Time authorization error: \(error)")
                        await MainActor.run {
                            hasRequestedScreenTime = true // Mark as requested anyway
                        }
                    }
                }
            } else {
                // User can proceed even without authorization
                withAnimation {
                    currentStep = .selectApps
                }
            }
            
        case .selectApps:
            if !appSettings.hasSelectedApps && screenTimeService.isAuthorized {
                // Only show app selection if Screen Time is authorized
                showAppSelection = true
            } else {
                // Complete onboarding (with or without apps selected)
                onComplete()
            }
        }
    }
}

// MARK: - Supporting Types

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case notifications = 1
    case screenTime = 2
    case selectApps = 3
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(PaperTheme.accentBlue) // Fixed paper blue
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PaperTheme.textPrimary) // Fixed dark brown
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(PaperTheme.textSecondary) // Fixed medium brown
            }
            
            Spacer()
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PaperTheme.cardBackground)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(PaperTheme.border, lineWidth: 1)
                    )
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(PaperTheme.accentBlue) // Fixed paper blue
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(PaperTheme.textPrimary) // Fixed dark brown
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}

