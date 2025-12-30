//
//  NewOnboardingView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData
import FamilyControls

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case notifications = 1
    case screenTime = 2
    case selectApps = 3
    case createSchedule = 4
}

/// Onboarding view for schedule-based app blocking
struct NewOnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @ObservedObject var appSettings = AppSettings.shared
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var showAppSelection = false
    @State private var showScheduleEditor = false
    @State private var hasRequestedScreenTime = false
    @State private var hasRequestedNotifications = false
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicators
                    HStack(spacing: 8) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            Circle()
                                .fill(step.rawValue <= currentStep.rawValue ? PaperTheme.accentBlue : PaperTheme.border)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            stepView(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Navigation buttons
                    VStack(spacing: 12) {
                        Button(action: handlePrimaryAction) {
                            Text(primaryButtonTitle)
                                .font(.headline)
                                .foregroundColor(PaperTheme.buttonPrimaryText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PaperTheme.buttonPrimary)
                                .cornerRadius(12)
                        }
                        
                        HStack(spacing: 20) {
                            if currentStep != .welcome {
                                Button("Back") {
                                    withAnimation {
                                        currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .welcome
                                    }
                                }
                                .foregroundColor(PaperTheme.textSecondary)
                            }
                            
                            if currentStep == .notifications || currentStep == .screenTime {
                                Button("Skip for Now") {
                                    withAnimation {
                                        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                                            currentStep = nextStep
                                        }
                                    }
                                }
                                .foregroundColor(PaperTheme.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showAppSelection) {
            AppSelectionView()
        }
        .sheet(isPresented: $showScheduleEditor) {
            ScheduleEditorView()
        }
    }
    
    // MARK: - Step Views
    
    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                switch step {
                case .welcome:
                    welcomeView
                case .notifications:
                    notificationsView
                case .screenTime:
                    screenTimeView
                case .selectApps:
                    selectAppsView
                case .createSchedule:
                    createScheduleView
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
    
    // MARK: - Welcome
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 100))
                .foregroundColor(PaperTheme.accentBlue)
            
            Text("Welcome to Focus")
                .font(.largeTitle.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Block distracting apps on your schedule. Stay focused when it matters most.")
                .font(.body)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Notifications
    
    private var notificationsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(PaperTheme.accentOrange)
            
            Text("Enable Notifications")
                .font(.title.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Get notified when blocking starts and ends based on your schedule.")
                .font(.body)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if hasRequestedNotifications {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PaperTheme.accentGreen)
                    Text("Notifications enabled")
                        .foregroundColor(PaperTheme.textSecondary)
                }
                .padding()
                .background(PaperTheme.accentGreen.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Screen Time
    
    private var screenTimeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "shield.fill")
                .font(.system(size: 80))
                .foregroundColor(PaperTheme.accentBlue)
            
            Text("Screen Time Access")
                .font(.title.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Required to block apps. Tap below to grant access.")
                .font(.body)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if screenTimeService.isAuthorized {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PaperTheme.accentGreen)
                    Text("Access granted")
                        .foregroundColor(PaperTheme.textSecondary)
                }
                .padding()
                .background(PaperTheme.accentGreen.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Select Apps
    
    private var selectAppsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "app.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(PaperTheme.accentRed)
            
            Text("Select Apps to Block")
                .font(.title.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Choose which apps should be blocked during your scheduled times.")
                .font(.body)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if appSettings.selectedApps.applicationTokens.count > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PaperTheme.accentGreen)
                    Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                        .foregroundColor(PaperTheme.textSecondary)
                }
                .padding()
                .background(PaperTheme.accentGreen.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Create Schedule
    
    private var createScheduleView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(PaperTheme.accentPurple)
            
            Text("Create Your Schedule")
                .font(.title.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Set when apps should be blocked. You can create multiple schedules later.")
                .font(.body)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Quick preset buttons
            VStack(spacing: 12) {
                Button(action: { createPresetSchedule(type: .work) }) {
                    HStack {
                        Image(systemName: "briefcase.fill")
                        Text("Work Hours (9 AM - 5 PM)")
                        Spacer()
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(10)
                }
                
                Button(action: { createPresetSchedule(type: .sleep) }) {
                    HStack {
                        Image(systemName: "moon.fill")
                        Text("Sleep Time (10 PM - 7 AM)")
                        Spacer()
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(10)
                }
                
                Button(action: { showScheduleEditor = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Custom Schedule")
                        Spacer()
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(10)
                }
            }
            .foregroundColor(PaperTheme.textPrimary)
        }
    }
    
    // MARK: - Actions
    
    private var primaryButtonTitle: String {
        switch currentStep {
        case .welcome:
            return "Get Started"
        case .notifications:
            return hasRequestedNotifications ? "Continue" : "Enable Notifications"
        case .screenTime:
            return screenTimeService.isAuthorized ? "Continue" : "Grant Access"
        case .selectApps:
            return appSettings.selectedApps.applicationTokens.count > 0 ? "Continue" : "Select Apps"
        case .createSchedule:
            return "Finish"
        }
    }
    
    private func handlePrimaryAction() {
        switch currentStep {
        case .welcome:
            withAnimation {
                currentStep = .notifications
            }
            
        case .notifications:
            if !hasRequestedNotifications {
                Task {
                    await NotificationService.shared.requestAuthorization()
                    hasRequestedNotifications = true
                }
            } else {
                withAnimation {
                    currentStep = .screenTime
                }
            }
            
        case .screenTime:
            if !screenTimeService.isAuthorized {
                Task {
                    try? await screenTimeService.requestAuthorization()
                    hasRequestedScreenTime = true
                }
            } else {
                withAnimation {
                    currentStep = .selectApps
                }
            }
            
        case .selectApps:
            if appSettings.selectedApps.applicationTokens.count == 0 {
                showAppSelection = true
            } else {
                withAnimation {
                    currentStep = .createSchedule
                }
            }
            
        case .createSchedule:
            onComplete()
        }
    }
    
    enum PresetType {
        case work, sleep
    }
    
    private func createPresetSchedule(type: PresetType) {
        let calendar = Calendar.current
        let schedule: BlockingSchedule
        
        switch type {
        case .work:
            schedule = BlockingSchedule(
                name: "Work Hours",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date(),
                daysOfWeek: [2, 3, 4, 5, 6], // Mon-Fri
                isEnabled: true
            )
        case .sleep:
            schedule = BlockingSchedule(
                name: "Sleep Time",
                startTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
                isEnabled: true
            )
        }
        
        ScheduleService.shared.setModelContext(modelContext)
        ScheduleService.shared.addSchedule(schedule)
        
        // Complete onboarding
        onComplete()
    }
}

#Preview {
    NewOnboardingView(onComplete: {})
        .modelContainer(for: [BlockingSchedule.self], inMemory: true)
}

