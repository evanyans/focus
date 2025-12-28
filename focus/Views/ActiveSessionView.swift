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
        VStack(spacing: 40) {
            Spacer()
            
            // Session status
            Text("Focus Session")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            // Timer display
            Text(viewModel.formatTime(viewModel.remainingTime))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
            
            // Progress indicator
            Text("Stay focused")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // End session button
            Button(action: {
                viewModel.endSession()
            }) {
                Text("End Session")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview("Active Session") {
    FocusSessionView()
}

