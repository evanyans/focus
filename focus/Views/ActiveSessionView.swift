//
//  ActiveSessionView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-26.
//

import SwiftUI

/// View displaying the active focus session with countdown timer
struct ActiveSessionView: View {
    @ObservedObject var viewModel: FocusSessionViewModel
    
    var body: some View {
        ZStack {
            // Paper background
            PaperTheme.background
                .ignoresSafeArea()
            
            // Subtle paper texture
            PaperTheme.textureOverlay
                .opacity(0.3)
                .ignoresSafeArea()
                .blendMode(.multiply)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Session status
                Text("Focus Session")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(PaperTheme.textPrimary)
                
                // Timer display with paper card
                VStack(spacing: 12) {
                    Text(viewModel.formatTime(viewModel.remainingTime))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(PaperTheme.textPrimary)
                    
                    Text("Stay focused")
                        .font(.body)
                        .foregroundStyle(PaperTheme.textSecondary)
                }
                .padding(.vertical, 50)
                .padding(.horizontal, 40)
                .background(PaperTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PaperTheme.border, lineWidth: 2)
                )
                .shadow(color: PaperTheme.shadow, radius: 6, x: 3, y: 4)
                
                Spacer()
                
                // End session button - paper style
                Button(action: {
                    viewModel.endSession()
                }) {
                    Text("End Session")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(PaperTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(PaperTheme.accentRed)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(PaperTheme.border, lineWidth: 1)
                        )
                        .shadow(color: PaperTheme.shadow, radius: 4, x: 2, y: 3)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .padding()
        }
    }
}

#Preview("Active Session") {
    FocusSessionView()
}

