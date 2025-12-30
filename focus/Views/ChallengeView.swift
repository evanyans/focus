//
//  ChallengeView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData

struct ChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var answer: String = ""
    @State private var showError: Bool = false
    @State private var attempts: Int = 0
    
    let num1: Int
    let num2: Int
    let correctAnswer: Int
    
    init() {
        // Generate random math problem
        self.num1 = Int.random(in: 10...50)
        self.num2 = Int.random(in: 10...50)
        self.correctAnswer = num1 * num2
    }
    
    var body: some View {
        ZStack {
            PaperTheme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(PaperTheme.accentOrange)
                    
                    Text("Solve to Unlock")
                        .font(.title.bold())
                        .foregroundColor(PaperTheme.textPrimary)
                    
                    Text("Complete this challenge to temporarily disable blocking for 5 minutes")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Math Problem Card
                VStack(spacing: 20) {
                    Text("What is:")
                        .font(.headline)
                        .foregroundColor(PaperTheme.textSecondary)
                    
                    Text("\(num1) × \(num2)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(PaperTheme.textPrimary)
                    
                    // Answer Input
                    TextField("Your answer", text: $answer)
                        .font(.title2)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(PaperTheme.background)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showError ? PaperTheme.accentRed : PaperTheme.border, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    
                    if showError {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Incorrect. Try again.")
                        }
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.accentRed)
                        .transition(.opacity)
                    }
                }
                .padding(24)
                .background(PaperTheme.cardBackground)
                .cornerRadius(16)
                .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: checkAnswer) {
                        Text("Submit Answer")
                            .font(.headline)
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PaperTheme.buttonPrimary)
                            .cornerRadius(12)
                    }
                    .disabled(answer.isEmpty)
                    .opacity(answer.isEmpty ? 0.5 : 1.0)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(PaperTheme.buttonSecondaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PaperTheme.buttonSecondary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: answer) { _, _ in
            showError = false
        }
    }
    
    private func checkAnswer() {
        attempts += 1
        
        guard let userAnswer = Int(answer) else {
            showError = true
            return
        }
        
        if userAnswer == correctAnswer {
            // Correct! Create override session
            let durationMinutes = 5
            let override = OverrideSession(durationMinutes: durationMinutes, challengeType: "math")
            override.wasUsed = true  // Mark as used immediately (user will access apps)
            modelContext.insert(override)
            
            // Log the override usage attempt
            let usageAttempt = UsageAttempt(
                appName: "Override Used",
                wasBlocked: false,
                overrideMethod: "challenge"
            )
            modelContext.insert(usageAttempt)
            
            do {
                try modelContext.save()
                print("✅ Challenge completed! Override granted for \(durationMinutes) minutes")
                print("📊 Logged override usage attempt")
                
                // Remove blocking temporarily
                ScreenTimeService.shared.removeBlocking()
                
                // Schedule notification before override expires (warn 1 minute before)
                let expiresIn = TimeInterval(durationMinutes * 60)
                Task {
                    await NotificationService.shared.scheduleOverrideExpiringNotification(expiresIn: expiresIn)
                }
                
                // Show success and dismiss
                dismiss()
            } catch {
                print("Failed to save override session: \(error)")
            }
        } else {
            // Incorrect
            showError = true
            answer = ""
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ChallengeView()
        .modelContainer(for: [OverrideSession.self], inMemory: true)
}

