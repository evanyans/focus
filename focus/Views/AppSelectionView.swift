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
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Select Apps to Block")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose which apps to block during your focus sessions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                            .foregroundStyle(.green)
                        
                        Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                            .font(.headline)
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        
                        Text("No apps selected yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Select apps button
                    Button(action: {
                        showPicker = true
                    }) {
                        Label("Choose Apps", systemImage: "hand.tap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    // Done button (only show if apps selected)
                    if appSettings.hasSelectedApps {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if appSettings.hasSelectedApps {
                        Button("Cancel") {
                            dismiss()
                        }
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

