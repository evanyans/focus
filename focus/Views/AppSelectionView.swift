//
//  AppSelectionView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI
import FamilyControls

/// View for selecting apps to block during focus sessions
struct AppSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appSettings = AppSettings.shared
    @State private var showPicker = false
    
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
                
                VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(PaperTheme.accentBlue)
                    
                    Text("Select Apps to Block")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(PaperTheme.textPrimary)
                    
                    Text("Choose which apps to block during your focus sessions")
                        .font(.subheadline)
                        .foregroundStyle(PaperTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Show selected apps count
                if appSettings.hasSelectedApps {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(PaperTheme.accentGreen)
                        
                        Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                            .font(.headline)
                            .foregroundStyle(PaperTheme.textPrimary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 50))
                            .foregroundStyle(PaperTheme.textTertiary)
                        
                        Text("No apps selected yet")
                            .font(.headline)
                            .foregroundStyle(PaperTheme.textSecondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Important note
                    if !appSettings.hasSelectedApps {
                        VStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(PaperTheme.accentBlue)
                            Text("After selecting apps, tap 'Done' in the picker before closing this screen")
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
                    
                    // Select apps button - paper style
                    Button(action: {
                        showPicker = true
                    }) {
                        Label("Choose Apps", systemImage: "hand.tap")
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
                            .shadow(color: PaperTheme.shadow, radius: 4, x: 2, y: 3)
                    }
                    
                    // Done button (only show if apps selected)
                    if appSettings.hasSelectedApps {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(PaperTheme.textPrimary)
                                .frame(maxWidth: .infinity)
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
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if appSettings.hasSelectedApps {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(PaperTheme.accentBlue)
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $showPicker,
                selection: $appSettings.selectedApps
            )
        }
    }
}

#Preview {
    AppSelectionView()
}

