//
//  SessionHistoryView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData

/// View displaying history of completed focus sessions
struct SessionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats summary
                    statsSection
                    
                    // Session list
                    if sessions.isEmpty {
                        emptyStateView
                    } else {
                        sessionsListView
                    }
                }
                .padding()
            }
            .navigationTitle("Focus History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Your Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Total sessions
                StatCard(
                    title: "Sessions",
                    value: "\(sessions.count)",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                // Total time
                StatCard(
                    title: "Total Time",
                    value: formatTotalTime(totalFocusTime),
                    icon: "clock.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                // Completed sessions
                StatCard(
                    title: "Completed",
                    value: "\(completedSessionsCount)",
                    icon: "star.fill",
                    color: .orange
                )
                
                // Ended early
                StatCard(
                    title: "Ended Early",
                    value: "\(endedEarlyCount)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
            }
        }
    }
    
    // MARK: - Sessions List
    
    private var sessionsListView: some View {
        VStack(spacing: 16) {
            Text("Recent Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(sessions) { session in
                    SessionRow(session: session)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteSession(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete a focus session to see it here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Computed Properties
    
    private var totalFocusTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.actualDuration }
    }
    
    private var completedSessionsCount: Int {
        sessions.filter { $0.wasCompleted }.count
    }
    
    private var endedEarlyCount: Int {
        sessions.filter { !$0.wasCompleted }.count
    }
    
    // MARK: - Helper Methods
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func deleteSession(_ session: FocusSession) {
        modelContext.delete(session)
        try? modelContext.save()
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Session Row Component

struct SessionRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Status icon
            Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(session.wasCompleted ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                // Date and time
                Text(session.startTime, style: .date)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    // Duration
                    Label(formatDuration(session.actualDuration), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Status
                    Text(session.wasCompleted ? "Completed" : "Ended Early")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Time
            Text(session.startTime, style: .time)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

#Preview {
    SessionHistoryView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}

