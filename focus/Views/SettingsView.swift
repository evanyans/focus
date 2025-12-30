//
//  SettingsView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI
import FamilyControls

/// Settings screen for managing blocked apps and preferences
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @State private var showAppSelection = false
    @State private var showScreenTimeHelp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Paper background
                PaperTheme.background
                    .ignoresSafeArea()
                
                List {
                // Screen Time Status Section
                Section {
                    HStack {
                        Image(systemName: "hourglass")
                            .foregroundStyle(screenTimeService.isAuthorized ? .green : .orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Screen Time Access")
                                .foregroundStyle(.primary)
                            
                            Text(screenTimeService.isAuthorized ? "Enabled" : "Not Enabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !screenTimeService.isAuthorized {
                            Button(action: {
                                showScreenTimeHelp = true
                            }) {
                                Text("Setup")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Required to block apps during focus sessions")
                }
                
                // Blocked Apps Section
                Section {
                    Button(action: {
                        showAppSelection = true
                    }) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundStyle(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Blocked Apps")
                                    .foregroundStyle(.primary)
                                
                                if appSettings.hasSelectedApps {
                                    Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Tap to select apps")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!screenTimeService.isAuthorized)
                } header: {
                    Text("Focus Settings")
                } footer: {
                    if screenTimeService.isAuthorized {
                        Text("Choose which apps to block during your focus sessions")
                    } else {
                        Text("Enable Screen Time Access first to select apps")
                    }
                }
                
                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
                .scrollContentBackground(.hidden) // Hide default List background
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(PaperTheme.textPrimary)
                }
            }
            .sheet(isPresented: $showAppSelection) {
                AppSelectionView()
            }
            .sheet(isPresented: $showScreenTimeHelp) {
                ScreenTimeInstructionsView()
            }
        }
    }
}

/// Dedicated view with Screen Time setup instructions
struct ScreenTimeInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @State private var isRequesting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    Image(systemName: "hourglass.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(PaperTheme.accentOrange)
                        .padding(.top, 40)
                    
                    Text("Enable Screen Time Access")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(PaperTheme.textPrimary)
                    
                    Text("Tap the button below to request permission")
                        .font(.body)
                        .foregroundStyle(PaperTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // What will happen
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What will happen:")
                            .font(.headline)
                            .foregroundStyle(PaperTheme.textPrimary)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Text("1")
                                    .font(.headline.bold())
                                    .foregroundColor(PaperTheme.accentBlue)
                                    .frame(width: 32, height: 32)
                                    .background(PaperTheme.accentBlue.opacity(0.1))
                                    .clipShape(Circle())
                                Text("Tap 'Request Permission' below")
                                    .font(.subheadline)
                                    .foregroundColor(PaperTheme.textPrimary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Text("2")
                                    .font(.headline.bold())
                                    .foregroundColor(PaperTheme.accentBlue)
                                    .frame(width: 32, height: 32)
                                    .background(PaperTheme.accentBlue.opacity(0.1))
                                    .clipShape(Circle())
                                Text("iOS will show a system dialog")
                                    .font(.subheadline)
                                    .foregroundColor(PaperTheme.textPrimary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Text("3")
                                    .font(.headline.bold())
                                    .foregroundColor(PaperTheme.accentBlue)
                                    .frame(width: 32, height: 32)
                                    .background(PaperTheme.accentBlue.opacity(0.1))
                                    .clipShape(Circle())
                                Text("Tap 'Continue' to grant access")
                                    .font(.subheadline)
                                    .foregroundColor(PaperTheme.textPrimary)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(PaperTheme.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PaperTheme.border, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Request button
                    if !screenTimeService.isAuthorized {
                        Button(action: {
                            isRequesting = true
                            Task {
                                do {
                                    try await screenTimeService.requestAuthorization()
                                } catch {
                                    print("Failed to request authorization: \(error)")
                                }
                                await MainActor.run {
                                    isRequesting = false
                                }
                            }
                        }) {
                            HStack {
                                if isRequesting {
                                    ProgressView()
                                        .tint(PaperTheme.buttonPrimaryText)
                                } else {
                                    Image(systemName: "hand.tap")
                                }
                                Text(isRequesting ? "Requesting..." : "Request Permission")
                            }
                            .font(.headline)
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PaperTheme.buttonPrimary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(PaperTheme.border, lineWidth: 1)
                            )
                        }
                        .disabled(isRequesting)
                        .padding(.horizontal, 40)
                    }
                    
                    // Status
                    if screenTimeService.isAuthorized {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(PaperTheme.accentGreen)
                                Text("Access Granted!")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(PaperTheme.textPrimary)
                            }
                            
                            Text("You can now select apps to block during focus sessions")
                                .font(.subheadline)
                                .foregroundStyle(PaperTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(PaperTheme.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PaperTheme.border, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Screen Time Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

