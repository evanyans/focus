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
                Color(red: 0.99, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                // Subtle paper texture
                Color(red: 0.96, green: 0.95, blue: 0.92)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blendMode(.multiply)
                
                VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.6))
                    
                    Text("Select Apps to Block")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.1))
                    
                    Text("Choose which apps to block during your focus sessions")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.4, green: 0.35, blue: 0.3))
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
                            .foregroundStyle(Color(red: 0.5, green: 0.6, blue: 0.45))
                        
                        Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.1))
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 50))
                            .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.4))
                        
                        Text("No apps selected yet")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.4, green: 0.35, blue: 0.3))
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
                                .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.6))
                            Text("After selecting apps, tap 'Done' in the picker before closing this screen")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.4, green: 0.35, blue: 0.3))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(red: 0.97, green: 0.96, blue: 0.93))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.85, green: 0.83, blue: 0.78), lineWidth: 1)
                        )
                    }
                    
                    // Select apps button - paper style
                    Button(action: {
                        showPicker = true
                    }) {
                        Label("Choose Apps", systemImage: "hand.tap")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.95, green: 0.94, blue: 0.91))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.3, green: 0.25, blue: 0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.4, green: 0.35, blue: 0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 3)
                    }
                    
                    // Done button (only show if apps selected)
                    if appSettings.hasSelectedApps {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.2))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.97, green: 0.96, blue: 0.93))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.85, green: 0.83, blue: 0.78), lineWidth: 1)
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
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $showPicker,
                selection: $appSettings.selectedApps
            )
        }
        .preferredColorScheme(.light) // Force light mode for paper background
    }
}

#Preview {
    AppSelectionView()
}

