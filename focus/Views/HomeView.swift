//
//  HomeView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData
import FamilyControls

/// Main home screen showing blocking status and usage stats
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UsageAttempt.timestamp, order: .reverse) private var usageAttempts: [UsageAttempt]
    @Query(sort: \OverrideSession.startTime, order: .reverse) private var overrideSessions: [OverrideSession]
    @Query(sort: \BlockingSchedule.createdAt, order: .forward) private var schedules: [BlockingSchedule]
    
    @ObservedObject private var scheduleService = ScheduleService.shared
    @ObservedObject private var appSettings = AppSettings.shared
    
    @State private var showScheduleEditor = false
    @State private var showSettings = false
    @State private var showChallengeView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Blocking Status Card
                        blockingStatusCard
                        
                        // Blocked Apps Card
                        blockedAppsCard
                        
                        // Streak Card
                        streakCard
                        
                        // Today's Stats
                        todayStatsCard
                        
                        // Recent Attempts
                        recentAttemptsCard
                        
                        // Schedules List
                        schedulesCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Focus")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(PaperTheme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showScheduleEditor) {
                ScheduleEditorView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showChallengeView) {
                ChallengeView()
            }
            .onAppear {
                scheduleService.setModelContext(modelContext)
            }
        }
    }
    
    // MARK: - Blocking Status Card
    
    private var blockingStatusCard: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(scheduleService.isBlockingActive ? PaperTheme.accentRed.opacity(0.2) : PaperTheme.accentGreen.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: scheduleService.isBlockingActive ? "shield.fill" : "shield.slash.fill")
                    .font(.system(size: 40))
                    .foregroundColor(scheduleService.isBlockingActive ? PaperTheme.accentRed : PaperTheme.accentGreen)
            }
            
            // Status Text
            VStack(spacing: 4) {
                Text(scheduleService.isBlockingActive ? "Blocking Active" : "Blocking Inactive")
                    .font(.title2.bold())
                    .foregroundColor(PaperTheme.textPrimary)
                
                if let schedule = scheduleService.activeSchedule {
                    Text(schedule.name)
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                    
                    Text("Until \(schedule.timeRangeString().split(separator: "-").last ?? "")")
                        .font(.caption)
                        .foregroundColor(PaperTheme.textTertiary)
                } else if let nextChange = scheduleService.nextScheduleChange {
                    Text("Next: \(formatTime(nextChange))")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                } else {
                    Text("No active schedules")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                }
            }
            
            // Override Button (only show when blocking is active)
            if scheduleService.isBlockingActive {
                if let activeOverride = scheduleService.getActiveOverride() {
                    // Show remaining override time
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(PaperTheme.accentOrange)
                        Text("Override active: \(formatSeconds(Int(activeOverride.remainingSeconds)))")
                            .font(.subheadline.bold())
                            .foregroundColor(PaperTheme.accentOrange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(PaperTheme.accentOrange.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Button(action: { showChallengeView = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                            Text("Solve Challenge to Unlock")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(PaperTheme.buttonPrimaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(PaperTheme.buttonPrimary)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(PaperTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Blocked Apps Card
    
    private var blockedAppsCard: some View {
        Button(action: { showSettings = true }) {
            HStack(spacing: 16) {
                Image(systemName: "app.badge.fill")
                    .font(.title2)
                    .foregroundColor(PaperTheme.accentRed)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blocked Apps")
                        .font(.headline)
                        .foregroundColor(PaperTheme.textPrimary)
                    
                    Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(PaperTheme.textTertiary)
            }
            .padding(20)
            .background(PaperTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        let streak = StreakService.calculateStreak(overrideSessions: overrideSessions)
        
        return HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(streak) Day Streak")
                    .font(.title3.bold())
                    .foregroundColor(PaperTheme.textPrimary)
                
                Text(StreakService.streakMessage(for: streak))
                    .font(.caption)
                    .foregroundColor(PaperTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Today's Stats
    
    private var todayStatsCard: some View {
        let todayAttempts = usageAttempts.filter { $0.isToday }
        let blockedCount = todayAttempts.filter { $0.wasBlocked }.count
        let overrideCount = todayAttempts.filter { !$0.wasBlocked }.count
        
        return VStack(spacing: 16) {
            HStack {
                Text("Today's Activity")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Blocks
                VStack(spacing: 8) {
                    Text("\(blockedCount)")
                        .font(.title.bold())
                        .foregroundColor(PaperTheme.accentGreen)
                    Text("Blocks")
                        .font(.caption)
                        .foregroundColor(PaperTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(PaperTheme.accentGreen.opacity(0.1))
                .cornerRadius(10)
                
                // Overrides
                VStack(spacing: 8) {
                    Text("\(overrideCount)")
                        .font(.title.bold())
                        .foregroundColor(PaperTheme.accentOrange)
                    Text("Overrides")
                        .font(.caption)
                        .foregroundColor(PaperTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(PaperTheme.accentOrange.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Recent Attempts
    
    private var recentAttemptsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
            }
            
            if usageAttempts.isEmpty {
                Text("No activity yet")
                    .font(.subheadline)
                    .foregroundColor(PaperTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(usageAttempts.prefix(5)), id: \.id) { attempt in
                        HStack(spacing: 12) {
                            Image(systemName: attempt.wasBlocked ? "shield.fill" : "lock.open.fill")
                                .foregroundColor(attempt.wasBlocked ? PaperTheme.accentGreen : PaperTheme.accentOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attempt.appName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(PaperTheme.textPrimary)
                                
                                Text(attempt.formattedTime())
                                    .font(.caption)
                                    .foregroundColor(PaperTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text(attempt.wasBlocked ? "Blocked" : "Override")
                                .font(.caption.bold())
                                .foregroundColor(attempt.wasBlocked ? PaperTheme.accentGreen : PaperTheme.accentOrange)
                        }
                        .padding(12)
                        .background(PaperTheme.background)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Schedules Card
    
    private var schedulesCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Schedules")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
                Button(action: { showScheduleEditor = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PaperTheme.buttonPrimary)
                }
            }
            
            if schedules.isEmpty {
                VStack(spacing: 12) {
                    Text("No schedules yet")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textTertiary)
                    
                    Button(action: { showScheduleEditor = true }) {
                        Text("Create Your First Schedule")
                            .font(.subheadline.bold())
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(PaperTheme.buttonPrimary)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(schedules, id: \.id) { schedule in
                        ScheduleRow(schedule: schedule)
                    }
                }
            }
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Schedule Row

struct ScheduleRow: View {
    let schedule: BlockingSchedule
    @ObservedObject private var scheduleService = ScheduleService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in scheduleService.toggleSchedule(schedule) }
            ))
            .labelsHidden()
            .tint(PaperTheme.accentGreen)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .font(.subheadline.bold())
                    .foregroundColor(PaperTheme.textPrimary)
                
                Text(schedule.timeRangeString())
                    .font(.caption)
                    .foregroundColor(PaperTheme.textSecondary)
                
                Text(schedule.daysString())
                    .font(.caption)
                    .foregroundColor(PaperTheme.textTertiary)
            }
            
            Spacer()
            
            if schedule.isActiveNow() && schedule.isEnabled {
                Text("Active")
                    .font(.caption.bold())
                    .foregroundColor(PaperTheme.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PaperTheme.accentGreen.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(PaperTheme.background)
        .cornerRadius(8)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [BlockingSchedule.self, UsageAttempt.self, OverrideSession.self], inMemory: true)
}

