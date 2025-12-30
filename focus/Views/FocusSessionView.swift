//
//  FocusSessionView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI
import SwiftData
import FamilyControls

/// Main view for the focus app - shows start button or active session
struct FocusSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    
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
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        VStack(spacing: 12) {
            // Top row
            HStack(spacing: 12) {
                // Total sessions
                StatBox(
                    value: "\(sessions.count)",
                    label: "Sessions",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                // Total time
                StatBox(
                    value: formatTotalTime(totalFocusTime),
                    label: "Total Time",
                    icon: "clock.fill",
                    color: .green
                )
            }
            
            // Bottom row
            HStack(spacing: 12) {
                // Completed
                StatBox(
                    value: "\(completedSessionsCount)",
                    label: "Completed",
                    icon: "star.fill",
                    color: .orange
                )
                
                // Completion rate
                StatBox(
                    value: "\(completionPercentage)%",
                    label: "Rate",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Recent Sessions List
    
    private var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                ForEach(sessions.prefix(10)) { session in
                    CompactSessionRow(session: session)
                }
                
                // Show "View All" if more than 10 sessions
                if sessions.count > 10 {
                    Button(action: {
                        showHistory = true
                    }) {
                        HStack {
                            Text("View All \(sessions.count) Sessions")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalFocusTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.actualDuration }
    }
    
    private var completedSessionsCount: Int {
        sessions.filter { $0.wasCompleted }.count
    }
    
    private var completionPercentage: Int {
        guard !sessions.isEmpty else { return 0 }
        let completed = sessions.filter { $0.wasCompleted }.count
        return Int((Double(completed) / Double(sessions.count)) * 100)
    }
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
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
                    // Show start button and history
                    ScrollView {
                        VStack(spacing: 24) {
                            // App title
                            Text("Focus")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.primary)
                                .padding(.top, 40)
                            
                            // Start button
                            Button(action: {
                                viewModel.startSession()
                            }) {
                                Text("Start Focus Session")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            
                            // Stats and sessions
                            if !sessions.isEmpty {
                                VStack(spacing: 20) {
                                    // Stats cards
                                    statsGrid
                                    
                                    // Recent sessions list
                                    recentSessionsList
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer(minLength: 40)
                        }
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
            .sheet(isPresented: $showHistory) {
                SessionHistoryView()
            }
        }
    }
}

// MARK: - StatBox Component

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - CompactSessionRow Component

struct CompactSessionRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(session.wasCompleted ? .green : .orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                // Duration and status
                HStack(spacing: 8) {
                    Text(formatDuration(session.actualDuration))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(session.wasCompleted ? "Completed" : "Ended Early")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Static date
                Text(formatDate(session.startTime))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Time
            Text(session.startTime, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    FocusSessionView()
}

