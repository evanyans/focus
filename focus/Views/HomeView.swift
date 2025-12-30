//
//  HomeView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData
import FamilyControls
import Combine

/// Main home screen showing blocking status and usage stats
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UsageAttempt.timestamp, order: .reverse) private var usageAttempts: [UsageAttempt]
    @Query(sort: \OverrideSession.startTime, order: .reverse) private var overrideSessions: [OverrideSession]
    @Query(sort: \BlockingSchedule.createdAt, order: .forward) private var schedules: [BlockingSchedule]
    
    @ObservedObject private var scheduleService = ScheduleService.shared
    @ObservedObject private var appSettings = AppSettings.shared
    
    @State private var showScheduleEditor = false
    @State private var showSettings = false
    @State private var showChallengeView = false
    @State private var showStreakDetail = false
    @State private var currentTime = Date()  // For real-time countdown updates
    @State private var dailyQuote = ""  // Daily motivational quote
    
    // Timer that fires every second for countdown
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Blocking Status Card (with streak indicator)
                        blockingStatusCard
                        
                        // Daily Quote Card
                        quoteCard
                        
                        // Blocked Apps Card
                        blockedAppsCard
                        
                        // Today's Stats (Overrides)
                        todayStatsCard
                        
                        // Schedules List
                        schedulesCard
                        
                        // Recent Activity (moved to bottom)
                        recentAttemptsCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Focus")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(PaperTheme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showScheduleEditor) {
                ScheduleEditorView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showChallengeView) {
                ChallengeView()
            }
            .sheet(isPresented: $showStreakDetail) {
                StreakDetailView(overrideSessions: overrideSessions)
            }
            .onAppear {
                scheduleService.setModelContext(modelContext)
                // Force immediate check when view appears
                scheduleService.checkSchedules()
                // Set daily quote
                dailyQuote = getDailyQuote()
            }
            .onReceive(timer) { time in
                // Update current time every second for countdown
                currentTime = time
            }
        }
    }
    
    // MARK: - Blocking Status Card
    
    private var blockingStatusCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(scheduleService.isBlockingActive ? PaperTheme.accentRed.opacity(0.2) : PaperTheme.accentGreen.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: scheduleService.isBlockingActive ? "shield.fill" : "shield.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(scheduleService.isBlockingActive ? PaperTheme.accentRed : PaperTheme.accentGreen)
                }
                
                // Status Text
                VStack(spacing: 4) {
                    Text(scheduleService.isBlockingActive ? "Blocking Active" : "Blocking Inactive")
                        .font(.title2.bold())
                        .foregroundColor(PaperTheme.textPrimary)
                    
                    if let schedule = scheduleService.activeSchedule {
                        Text(schedule.name)
                            .font(.subheadline)
                            .foregroundColor(PaperTheme.textSecondary)
                        
                        // Show override status if active
                        if scheduleService.isOverrideActive, let override = scheduleService.activeOverride {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                Text("Override: \(timeRemaining(until: override.endTime))")
                                    .font(.caption)
                            }
                            .foregroundColor(PaperTheme.accentOrange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(PaperTheme.accentOrange.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            Text("Until \(schedule.timeRangeString().split(separator: "-").last ?? "")")
                                .font(.caption)
                                .foregroundColor(PaperTheme.textTertiary)
                        }
                    } else if let nextChange = scheduleService.nextScheduleChange {
                        Text("Next: \(formatTime(nextChange))")
                            .font(.subheadline)
                            .foregroundColor(PaperTheme.textSecondary)
                    } else {
                        Text("No active schedules")
                            .font(.subheadline)
                            .foregroundColor(PaperTheme.textSecondary)
                    }
                }
                
                // Override Button (only show when blocking is active and no override)
                if scheduleService.isBlockingActive && !scheduleService.isOverrideActive {
                    Button(action: { showChallengeView = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                            Text("Solve Challenge to Unlock")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(PaperTheme.buttonPrimaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(PaperTheme.buttonPrimary)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(PaperTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
            
            // Streak Indicator (top-right corner)
            Button(action: { showStreakDetail = true }) {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 18))
                    Text("\(StreakService.calculateStreak(overrideSessions: overrideSessions))")
                        .font(.subheadline.bold())
                        .foregroundColor(PaperTheme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PaperTheme.accentOrange.opacity(0.15))
                .cornerRadius(20)
            }
            .padding(12)
        }
    }
    
    // MARK: - Quote Card
    
    private var quoteCard: some View {
        VStack(spacing: 12) {
            Text("💭")
                .font(.system(size: 32))
            
            Text(getQuoteText())
                .font(.subheadline)
                .italic()
                .foregroundColor(PaperTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            
            if let author = getQuoteAuthor() {
                Text("— \(author)")
                    .font(.caption)
                    .foregroundColor(PaperTheme.textTertiary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    PaperTheme.cardBackground,
                    PaperTheme.cardBackground.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Blocked Apps Card
    
    private var blockedAppsCard: some View {
        Button(action: { showSettings = true }) {
            HStack(spacing: 16) {
                Image(systemName: "app.badge.fill")
                    .font(.title2)
                    .foregroundColor(PaperTheme.accentRed)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blocked Apps")
                        .font(.headline)
                        .foregroundColor(PaperTheme.textPrimary)
                    
                    Text("\(appSettings.selectedApps.applicationTokens.count) apps selected")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(PaperTheme.textTertiary)
            }
            .padding(20)
            .background(PaperTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Today's Stats
    
    private var todayStatsCard: some View {
        let todayOverrides = overrideSessions.filter { 
            Calendar.current.isDateInToday($0.startTime)
        }
        
        return VStack(spacing: 16) {
            HStack {
                Text("Today's Activity")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
            }
            
            // Overrides count (centered, prominent)
            VStack(spacing: 8) {
                Text("\(todayOverrides.count)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(PaperTheme.accentOrange)
                Text("Overrides Used")
                    .font(.subheadline)
                    .foregroundColor(PaperTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(PaperTheme.accentOrange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Recent Attempts
    
    private var recentAttemptsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
            }
            
            if usageAttempts.isEmpty {
                Text("No activity yet")
                    .font(.subheadline)
                    .foregroundColor(PaperTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(usageAttempts.prefix(5)), id: \.id) { attempt in
                        HStack(spacing: 12) {
                            Image(systemName: attempt.wasBlocked ? "shield.fill" : "lock.open.fill")
                                .foregroundColor(attempt.wasBlocked ? PaperTheme.accentGreen : PaperTheme.accentOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attempt.appName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(PaperTheme.textPrimary)
                                
                                Text(attempt.formattedTime())
                                    .font(.caption)
                                    .foregroundColor(PaperTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text(attempt.wasBlocked ? "Blocked" : "Override")
                                .font(.caption.bold())
                                .foregroundColor(attempt.wasBlocked ? PaperTheme.accentGreen : PaperTheme.accentOrange)
                        }
                        .padding(12)
                        .background(PaperTheme.background)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Schedules Card
    
    private var schedulesCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Schedules")
                    .font(.headline)
                    .foregroundColor(PaperTheme.textPrimary)
                Spacer()
                Button(action: { showScheduleEditor = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PaperTheme.buttonPrimary)
                }
            }
            
            if schedules.isEmpty {
                VStack(spacing: 12) {
                    Text("No schedules yet")
                        .font(.subheadline)
                        .foregroundColor(PaperTheme.textTertiary)
                    
                    Button(action: { showScheduleEditor = true }) {
                        Text("Create Your First Schedule")
                            .font(.subheadline.bold())
                            .foregroundColor(PaperTheme.buttonPrimaryText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(PaperTheme.buttonPrimary)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(schedules, id: \.id) { schedule in
                        ScheduleRow(schedule: schedule)
                    }
                }
            }
        }
        .padding(20)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: PaperTheme.shadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeRemaining(until date: Date) -> String {
        // Use currentTime to ensure UI updates every second
        let remaining = date.timeIntervalSince(currentTime)
        if remaining <= 0 {
            return "Expired"
        }
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Quote Helpers
    
    private func getDailyQuote() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % dailyQuotes.count
        return dailyQuotes[index]
    }
    
    private func getQuoteText() -> String {
        if dailyQuote.isEmpty { return "" }
        
        // Split on em dash or regular dash with author
        if let range = dailyQuote.range(of: " — ") {
            return String(dailyQuote[..<range.lowerBound])
        } else if let range = dailyQuote.range(of: " - ") {
            return String(dailyQuote[..<range.lowerBound])
        }
        return dailyQuote
    }
    
    private func getQuoteAuthor() -> String? {
        if dailyQuote.isEmpty { return nil }
        
        // Split on em dash
        if let range = dailyQuote.range(of: " — ") {
            return String(dailyQuote[range.upperBound...])
        } else if let range = dailyQuote.range(of: " - ") {
            return String(dailyQuote[range.upperBound...])
        }
        return nil
    }
    
    // MARK: - Quotes Database
    
    private let dailyQuotes = [
        // Focus & Attention
        "The successful warrior is the average man, with laser-like focus. — Bruce Lee",
        "Where focus goes, energy flows. — Tony Robbins",
        "Focus is the new IQ. — Cal Newport",
        "Attention is the rarest and purest form of generosity. — Simone Weil",
        "Focus on being productive instead of busy. — Tim Ferriss",
        "Starve your distractions, feed your focus.",
        "The key is not to prioritize what's on your schedule, but to schedule your priorities. — Stephen Covey",
        "Wherever you are, be all there. — Jim Elliot",
        "Multitasking is a lie. — Gary Keller",
        "What you focus on grows.",
        "Concentrate all your thoughts upon the work in hand. — Alexander Graham Bell",
        "One reason so few of us achieve what we truly want is that we never direct our focus. — Tony Robbins",
        "The shorter way to do many things is to only do one thing at a time. — Mozart",
        "It's not about time, it's about focus.",
        "Lack of direction, not lack of time, is the problem. — Zig Ziglar",
        
        // Deep Work & Productivity
        "Deep work is the ability to focus without distraction. — Cal Newport",
        "You can do anything, but not everything. — David Allen",
        "It's not the daily increase but daily decrease. Hack away at the unessential. — Bruce Lee",
        "The things which matter most must never be at the mercy of things which matter least. — Goethe",
        "Done is better than perfect. — Sheryl Sandberg",
        "The way to get started is to quit talking and begin doing. — Walt Disney",
        "Lost time is never found again. — Benjamin Franklin",
        "Either you run the day, or the day runs you. — Jim Rohn",
        "The best moments occur when a person is stretched to their limits. — Mihaly Csikszentmihalyi",
        "Amateurs wait for inspiration. The rest of us just get up and go to work. — Stephen King",
        "Do the hard jobs first. The easy jobs will take care of themselves. — Dale Carnegie",
        "The cost of a thing is the amount of life required for it. — Henry David Thoreau",
        "Simplicity: Identify the essential. Eliminate the rest. — Leo Babauta",
        "Efficiency is doing things right. Effectiveness is doing the right things. — Peter Drucker",
        "A goal without a plan is just a wish. — Antoine de Saint-Exupéry",
        "The secret of getting ahead is getting started. — Mark Twain",
        
        // Discipline & Consistency
        "Discipline is choosing between what you want now and what you want most. — Abraham Lincoln",
        "We are what we repeatedly do. Excellence is not an act but a habit. — Aristotle",
        "Success is the sum of small efforts, repeated day in and day out. — Robert Collier",
        "Motivation is what gets you started. Habit is what keeps you going. — Jim Ryun",
        "A journey of a thousand miles begins with a single step. — Lao Tzu",
        "The secret of your future is hidden in your daily routine. — Mike Murdock",
        "It's not what we do once in a while that shapes our lives. It's what we do consistently. — Tony Robbins",
        "The pain of discipline is far less than the pain of regret. — Sarah Bombell",
        "Discipline is the bridge between goals and accomplishment. — Jim Rohn",
        "Quality is not an act, it is a habit. — Aristotle",
        "You don't have to be great to start, but you have to start to be great. — Zig Ziglar",
        "Small daily improvements over time lead to stunning results. — Robin Sharma",
        "Consistency is the true foundation of trust. — Roy T. Bennett",
        "Success doesn't come from what you do occasionally but consistently. — Marie Forleo",
        "Self-discipline begins with the mastery of your thoughts. — Napoleon Hill",
        "Without self-discipline, success is impossible. — Lou Holtz",
        "True freedom is impossible without a mind made free by discipline. — Mortimer J. Adler",
        
        // Digital Wellbeing & Mindfulness
        "Be where your feet are.",
        "Almost everything will work again if you unplug it for a few minutes, including you. — Anne Lamott",
        "Life is what happens when you're busy looking at your phone.",
        "Be present. Make someone happy. Make someone smile.",
        "Technology is a useful servant but a dangerous master. — Christian Lous Lange",
        "The most precious gift we can offer anyone is our attention. — Thich Nhat Hanh",
        "Be here now. — Ram Dass",
        "The present moment is the only time over which we have dominion. — Thich Nhat Hanh",
        "The mind is like water. When it's calm, everything becomes clear. — Buddha",
        "Don't let technology take over your life. Use it to enhance your life.",
        "The secret to living well is to live less on screens and more in reality.",
        "The best thing to hold onto in life is each other. — Audrey Hepburn",
        "Your phone doesn't make you happy, experiences do.",
        "Wherever you go, there you are. — Jon Kabat-Zinn",
        "Don't believe everything you think.",
        "Life isn't about waiting for the storm to pass, it's about learning to dance in the rain. — Vivian Greene",
        "Yesterday is history, tomorrow is a mystery, today is a gift. — Eleanor Roosevelt",
        
        // Time Management
        "Your time is limited, don't waste it living someone else's life. — Steve Jobs",
        "Time is what we want most, but what we use worst. — William Penn",
        "The bad news is time flies. The good news is you're the pilot. — Michael Altshuler",
        "The key is in not spending time, but in investing it. — Stephen R. Covey",
        "How we spend our days is how we spend our lives. — Annie Dillard",
        "Don't count the days, make the days count. — Muhammad Ali",
        "Time you enjoyed wasting is not wasted time. — Marthe Troly-Curtin",
        "You have the same hours as Helen Keller, Einstein, and Da Vinci. — H. Jackson Brown Jr.",
        "Time is the most valuable thing a man can spend. — Theophrastus",
        "Those who make the worst use of their time complain of its brevity. — Jean de La Bruyère",
        "Time is free, but it's priceless. You can't own it, but you can use it. — Harvey MacKay",
        "Take care of the minutes and the hours will take care of themselves. — Lord Chesterfield",
        "Time management is life management. — Robin Sharma",
        "You may delay, but time will not. — Benjamin Franklin",
        "Time is the scarcest resource. Unless it is managed, nothing else can be managed. — Peter Drucker",
        
        // Modern/Tech-Specific
        "Don't optimize your phone. Optimize your life.",
        "The best notification is the one you don't receive.",
        "Scrolling is the new smoking.",
        "Your attention is worth more than any viral post.",
        "Real connections happen face to face.",
        "The algorithm wants your time. Don't give it away.",
        "Be the user, not the used.",
        "Choose intention over impulsiveness.",
        "Master your phone before it masters you.",
        "Freedom is one uninstalled app away.",
        
        // Closing Strong
        "Small choices, big life.",
        "Progress over perfection.",
        "Discipline today, freedom tomorrow.",
        "Be intentional. Be present. Be free.",
        "The best time was yesterday. The next best time is now.",
        "Every moment is a fresh start.",
        "You are the author of your own story.",
        "Focus on what matters. Forget the rest.",
        "Your future self will thank you.",
        "This is your time. Use it wisely."
    ]
}

// MARK: - Schedule Row

struct ScheduleRow: View {
    let schedule: BlockingSchedule
    @ObservedObject private var scheduleService = ScheduleService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in scheduleService.toggleSchedule(schedule) }
            ))
            .labelsHidden()
            .tint(PaperTheme.accentGreen)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .font(.subheadline.bold())
                    .foregroundColor(PaperTheme.textPrimary)
                
                Text(schedule.timeRangeString())
                    .font(.caption)
                    .foregroundColor(PaperTheme.textSecondary)
                
                Text(schedule.daysString())
                    .font(.caption)
                    .foregroundColor(PaperTheme.textTertiary)
            }
            
            Spacer()
            
            if schedule.isActiveNow() && schedule.isEnabled {
                Text("Active")
                    .font(.caption.bold())
                    .foregroundColor(PaperTheme.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PaperTheme.accentGreen.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(PaperTheme.background)
        .cornerRadius(8)
    }
}

// MARK: - Streak Detail View

struct StreakDetailView: View {
    let overrideSessions: [OverrideSession]
    @Environment(\.dismiss) private var dismiss
    
    private var currentStreak: Int {
        StreakService.calculateStreak(overrideSessions: overrideSessions)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        streakHeader
                        streakExplanation
                        overrideHistorySection
                    }
                    .padding()
                }
            }
            .navigationTitle("Streak History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(PaperTheme.accentBlue)
                }
            }
        }
    }
    
    private var streakHeader: some View {
        VStack(spacing: 8) {
            Text("🔥")
                .font(.system(size: 60))
            
            Text("\(currentStreak) Day Streak")
                .font(.title.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            Text(StreakService.streakMessage(for: currentStreak))
                .font(.subheadline)
                .foregroundColor(PaperTheme.textSecondary)
        }
        .padding(.vertical, 20)
    }
    
    private var streakExplanation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How Streaks Work")
                .font(.headline)
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("Your streak counts consecutive days without using overrides. Each time you use a challenge or watch an ad to unlock apps, your streak resets to zero.")
                .font(.subheadline)
                .foregroundColor(PaperTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PaperTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var overrideHistorySection: some View {
        Group {
            if !overrideSessions.isEmpty {
                overrideList
            } else {
                emptyState
            }
        }
    }
    
    private var overrideList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Overrides")
                .font(.headline)
                .foregroundColor(PaperTheme.textPrimary)
            
            ForEach(overrideSessions.prefix(20), id: \.id) { session in
                OverrideRow(session: session, isStreakBreaker: isStreakBreaker(session))
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🎯")
                .font(.system(size: 50))
            
            Text("No Overrides Yet")
                .font(.headline)
                .foregroundColor(PaperTheme.textPrimary)
            
            Text("You haven't used any overrides. Keep it up!")
                .font(.subheadline)
                .foregroundColor(PaperTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    private func isStreakBreaker(_ session: OverrideSession) -> Bool {
        let calendar = Calendar.current
        let sessionDay = calendar.startOfDay(for: session.startTime)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayStart = calendar.startOfDay(for: yesterday)
        
        // Show broken heart if this override happened yesterday or today
        return sessionDay >= yesterdayStart
    }
}

// MARK: - Override Row

struct OverrideRow: View {
    let session: OverrideSession
    let isStreakBreaker: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            iconView
            infoView
            Spacer()
            if isStreakBreaker {
                Text("💔")
                    .font(.title3)
            }
        }
        .padding(12)
        .background(PaperTheme.cardBackground)
        .cornerRadius(10)
    }
    
    private var iconView: some View {
        Image(systemName: session.challengeType == "math" ? "brain.head.profile" : "play.rectangle.fill")
            .font(.title3)
            .foregroundColor(session.challengeType == "math" ? PaperTheme.accentBlue : PaperTheme.accentPurple)
            .frame(width: 40)
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatDate(session.startTime))
                .font(.subheadline.bold())
                .foregroundColor(PaperTheme.textPrimary)
            
            detailsRow
        }
    }
    
    private var detailsRow: some View {
        HStack(spacing: 8) {
            Text(formatTime(session.startTime))
                .font(.caption)
                .foregroundColor(PaperTheme.textSecondary)
            
            Text("•")
                .foregroundColor(PaperTheme.textTertiary)
            
            Text("\(session.durationMinutes) min")
                .font(.caption)
                .foregroundColor(PaperTheme.textSecondary)
            
            Text("•")
                .foregroundColor(PaperTheme.textTertiary)
            
            Text(session.challengeType == "math" ? "Challenge" : "Ad")
                .font(.caption)
                .foregroundColor(PaperTheme.textTertiary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [BlockingSchedule.self, UsageAttempt.self, OverrideSession.self], inMemory: true)
}

