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
            Color(red: 0.99, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            // Subtle paper texture
            Color(red: 0.96, green: 0.95, blue: 0.92)
                .opacity(0.3)
                .ignoresSafeArea()
                .blendMode(.multiply)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Session status
                Text("Focus Session")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.1))
                
                // Timer display with paper card
                VStack(spacing: 12) {
                    Text(viewModel.formatTime(viewModel.remainingTime))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.1))
                    
                    Text("Stay focused")
                        .font(.body)
                        .foregroundStyle(Color(red: 0.4, green: 0.35, blue: 0.3))
                }
                .padding(.vertical, 50)
                .padding(.horizontal, 40)
                .background(Color(red: 0.97, green: 0.96, blue: 0.93))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.85, green: 0.83, blue: 0.78), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 3, y: 4)
                
                Spacer()
                
                // End session button - paper style
                Button(action: {
                    viewModel.endSession()
                }) {
                    Text("End Session")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.95, green: 0.94, blue: 0.91))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.6, green: 0.3, blue: 0.25)) // Warm reddish-brown
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.7, green: 0.4, blue: 0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 3)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .preferredColorScheme(.light) // Force light mode for paper background
    }
}

#Preview("Active Session") {
    FocusSessionView()
}

