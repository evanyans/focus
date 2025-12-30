# 🏗️ Focus App - Complete Architecture Overview

## 📱 App Concept

**Schedule-based app blocker** that blocks distracting apps based on recurring schedules (not manual timer sessions).

---

## 🎯 Core Flow

```
User Opens App
    ↓
Has Completed Onboarding?
    ├─ NO → NewOnboardingView (setup permissions & first schedule)
    └─ YES → HomeView (main screen)
         ↓
    HomeView shows:
         • Current blocking status
         • Blocked apps count
         • Streak (days without overrides)
         • Today's stats
         • Recent activity
         • All schedules (with toggles)
         ↓
    ScheduleService monitors time (every minute)
         ↓
    Schedule active? (e.g., 9am-5pm Mon-Fri)
    ├─ YES → Apply blocking
    │    ↓
    │    User tries to open blocked app
    │    ↓
    │    Shield screen appears
    │    ↓
    │    User opens app → Tap "Solve Challenge"
    │    ↓
    │    ChallengeView (math puzzle)
    │    ↓
    │    Correct answer?
    │    ├─ YES → 5-min override + streak breaks
    │    └─ NO → Try again
    │
    └─ NO → Remove blocking
```

---

## 🗂️ File Structure

### **📱 App Entry**
```
focusApp.swift
├─ Defines ModelContainer for SwiftData
├─ Registers models: BlockingSchedule, UsageAttempt, OverrideSession, FocusSession
└─ Shows MainAppView as root
```

### **📦 Data Models**

#### **AppState.swift**
- Tracks `hasCompletedOnboarding: Bool`
- Persists to UserDefaults
- Singleton: `AppState.shared`

#### **AppSettings.swift**
- Stores `selectedApps: FamilyActivitySelection` (blocked apps)
- Stores `defaultDuration: TimeInterval` (legacy, unused)
- Persists to UserDefaults
- Singleton: `AppSettings.shared`

#### **BlockingSchedule.swift** ✨ NEW
```swift
@Model class BlockingSchedule {
    var name: String              // "Work Hours"
    var startTime: Date           // 9:00 AM
    var endTime: Date             // 5:00 PM
    var daysOfWeek: [Int]         // [2,3,4,5,6] = Mon-Fri
    var isEnabled: Bool           // Toggle on/off
    
    func isActiveNow() -> Bool    // Check if currently active
}
```

#### **UsageAttempt.swift** ✨ NEW
```swift
@Model class UsageAttempt {
    var appName: String           // "Instagram"
    var timestamp: Date           // When attempted
    var wasBlocked: Bool          // true = blocked, false = override
    var overrideMethod: String?   // "challenge" if override used
}
```

#### **OverrideSession.swift** ✨ NEW
```swift
@Model class OverrideSession {
    var startTime: Date
    var endTime: Date             // 5 min after start
    var challengeType: String     // "math"
    var wasUsed: Bool             // Did user open blocked app?
    
    var isActive: Bool            // Check if still valid
}
```

#### **FocusSession.swift** (Legacy - kept for migration)
- Old session-based model
- Not actively used
- Kept to avoid SwiftData migration errors

---

### **⚙️ Services**

#### **ScheduleService.swift** ✨ NEW
```swift
@MainActor class ScheduleService: ObservableObject {
    @Published var isBlockingActive: Bool
    @Published var activeSchedule: BlockingSchedule?
    @Published var nextScheduleChange: Date?
    
    // Called every minute via Timer
    func checkSchedules() {
        // 1. Fetch all enabled schedules
        // 2. Check if any are active now
        // 3. If yes → applyBlocking()
        // 4. If no → removeBlocking()
    }
    
    func addSchedule(_ schedule: BlockingSchedule)
    func deleteSchedule(_ schedule: BlockingSchedule)
    func toggleSchedule(_ schedule: BlockingSchedule)
}
```

#### **ScreenTimeService.swift**
```swift
@MainActor class ScreenTimeService: ObservableObject {
    @Published var isAuthorized: Bool
    
    func requestAuthorization() async throws
    func applyBlocking(for selection: FamilyActivitySelection)
    func removeBlocking()
}
```
**Technologies:** `FamilyControls`, `ManagedSettings`

#### **NotificationService.swift**
```swift
class NotificationService {
    func requestAuthorization() async -> Bool
    func scheduleBlockingNotifications(for schedule: BlockingSchedule)
    func scheduleOverrideExpiringNotification(expiresIn: TimeInterval)
    func cancelBlockingNotifications()
}
```
**Technologies:** `UserNotifications` (local notifications)

#### **StreakService.swift**
```swift
class StreakService {
    static func calculateStreak(overrideSessions: [OverrideSession]) -> Int
    // Counts consecutive days WITHOUT using overrides
    // Resets to 0 if override used
}
```

#### **UsageTrackingService.swift** ✨ NEW (Placeholder)
```swift
@MainActor class UsageTrackingService: ObservableObject {
    func logAttempt(appName: String, wasBlocked: Bool, overrideMethod: String?)
    func getTodayAttempts() -> [UsageAttempt]
    func getWeekAttempts() -> [UsageAttempt]
}
```
**Note:** Automatic tracking requires DeviceActivity framework (complex setup, not yet implemented)

---

### **🎨 Views**

#### **MainAppView.swift** ✨ NEW
```swift
struct MainAppView: View {
    var body: some View {
        if !appState.hasCompletedOnboarding {
            NewOnboardingView(onComplete: { ... })
        } else {
            HomeView()
        }
    }
}
```

#### **NewOnboardingView.swift** ✨ NEW
```swift
enum OnboardingStep {
    case welcome, notifications, screenTime, selectApps, createSchedule
}

struct NewOnboardingView: View {
    // 5-step flow:
    // 1. Welcome
    // 2. Request notifications
    // 3. Request Screen Time access
    // 4. Select apps to block
    // 5. Create first schedule (presets or custom)
}
```

#### **HomeView.swift** ✨ NEW
```swift
struct HomeView: View {
    @Query var usageAttempts: [UsageAttempt]
    @Query var overrideSessions: [OverrideSession]
    @Query var schedules: [BlockingSchedule]
    
    var body: some View {
        ScrollView {
            blockingStatusCard    // Active/Inactive, override button
            blockedAppsCard       // Tap to edit selection
            streakCard            // 🔥 X Day Streak
            todayStatsCard        // Blocks vs Overrides
            recentAttemptsCard    // Last 5 attempts
            schedulesCard         // All schedules with toggles
        }
    }
}
```

#### **ScheduleEditorView.swift** ✨ NEW
```swift
struct ScheduleEditorView: View {
    @State var scheduleName: String
    @State var startTime: Date
    @State var endTime: Date
    @State var selectedDays: Set<Int>
    
    // UI for creating/editing schedules
    // Quick presets: Work, Sleep, Study
}
```

#### **ChallengeView.swift** ✨ NEW
```swift
struct ChallengeView: View {
    let num1: Int       // Random 10-50
    let num2: Int       // Random 10-50
    let correctAnswer: Int  // num1 × num2
    
    @State var answer: String
    @State var showError: Bool
    
    // User solves math problem
    // If correct → Create OverrideSession (5 min)
    //           → removeBlocking()
    //           → dismiss()
}
```

#### **AppSelectionView.swift**
```swift
struct AppSelectionView: View {
    @State var selection: FamilyActivitySelection
    
    var body: some View {
        FamilyActivityPicker(selection: $selection)
            .onChange(of: selection) { _, newValue in
                AppSettings.shared.selectedApps = newValue
            }
    }
}
```
**Technologies:** `FamilyControls.FamilyActivityPicker`

#### **SettingsView.swift**
```swift
struct SettingsView: View {
    // - Edit blocked apps
    // - Re-request Screen Time access
    // - Instructions for manual permission granting
}
```

---

### **🎨 Theme**

#### **PaperTheme.swift**
```swift
struct PaperTheme {
    // Adaptive colors (light/dark mode)
    static var background: Color        // System background
    static var cardBackground: Color    // Cream/Charcoal
    static var textPrimary: Color       // Dark brown/Light cream
    static var textSecondary: Color     // Medium brown/Gray-brown
    static var border: Color
    static var shadow: Color
    
    // Buttons
    static var buttonPrimary: Color     // Muted blue
    static var buttonPrimaryText: Color
    
    // Accents
    static var accentBlue: Color
    static var accentGreen: Color
    static var accentOrange: Color
    static var accentRed: Color
}
```

---

## 🔄 Key Interactions

### **1. Schedule Activation**
```swift
ScheduleService.checkSchedules() // Called every 60 seconds
    ↓
schedules.filter { $0.isActiveNow() }
    ↓
if activeSchedule exists:
    ScreenTimeService.shared.applyBlocking(for: AppSettings.shared.selectedApps)
    isBlockingActive = true
else:
    ScreenTimeService.shared.removeBlocking()
    isBlockingActive = false
```

### **2. Challenge Flow**
```swift
User taps "Solve Challenge to Unlock" in HomeView
    ↓
Present ChallengeView (math puzzle)
    ↓
User enters answer
    ↓
if correct:
    1. Create OverrideSession (5 min)
    2. modelContext.save()
    3. ScreenTimeService.shared.removeBlocking()
    4. dismiss()
    → Streak breaks (days without override resets to 0)
```

### **3. Streak Calculation**
```swift
StreakService.calculateStreak(overrideSessions: [OverrideSession])
    ↓
Group overrides by day where wasUsed = true
    ↓
Count consecutive days WITHOUT overrides
    ↓
if today or yesterday has override:
    streak = 0
else:
    streak = number of consecutive days
```

---

## 🧩 Technologies Used

### **SwiftUI**
- Declarative UI framework
- All views built with SwiftUI

### **SwiftData**
- Apple's persistence framework (successor to CoreData)
- Models: `@Model` macro
- Queries: `@Query` property wrapper
- Context: `@Environment(\.modelContext)`

### **FamilyControls Framework**
- `FamilyActivityPicker` - Select apps/categories
- `FamilyActivitySelection` - Holds selected apps
- `AuthorizationCenter` - Request Screen Time permission

### **ManagedSettings Framework**
- `ManagedSettingsStore` - Apply blocking rules
- `shield.applications` - Block apps
- Shield screen shown when app is blocked

### **UserNotifications**
- Local notifications
- Schedule-based alerts
- Override expiring warnings

### **Combine**
- `ObservableObject` protocol
- `@Published` property wrapper
- Used by all services for state updates

---

## 🔐 Permissions Required

### **Family Controls** (App Capability)
- Required for Screen Time API
- Must be added in Xcode: Signing & Capabilities → "+ Capability" → "Family Controls"
- Requires paid Apple Developer account

### **Notifications**
- Optional but recommended
- Requested in onboarding
- Alerts for schedule changes

---

## ⚠️ Known Limitations

### **1. Automatic Usage Tracking**
- **Current:** Manual/simulated tracking
- **Needed:** DeviceActivity framework + app extension
- **Why:** Complex setup, separate target required

### **2. Override Auto-Expiry**
- **Issue:** Can't force re-enable blocking after 5 min
- **Workaround:** Next schedule activation will reapply
- **Why:** Screen Time API limitation

### **3. Shield Screen Orientation**
- **Issue:** System shield may show in landscape
- **Fix:** Lock app to portrait in Xcode settings

### **4. Simulator Limitations**
- Screen Time API doesn't work fully in Simulator
- **Must test on real device**

---

## 🗄️ Data Flow

```
┌─────────────────┐
│   focusApp.swift │  ← Entry point
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  MainAppView     │  ← Router (onboarding or home)
└────────┬────────┘
         │
    ┌────┴─────┐
    │          │
    ▼          ▼
┌──────────┐ ┌─────────┐
│Onboarding│ │HomeView │
└──────────┘ └────┬────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
     ▼            ▼            ▼
┌─────────┐  ┌──────────┐  ┌─────────┐
│Schedule │  │Challenge │  │Settings │
│Editor   │  │View      │  │View     │
└─────────┘  └──────────┘  └─────────┘
     │            │            │
     └────────────┼────────────┘
                  │
     ┌────────────┴────────────┐
     │                         │
     ▼                         ▼
┌────────────────┐    ┌────────────────┐
│ScheduleService │    │ScreenTimeService│
└────────────────┘    └────────────────┘
     │                         │
     └─────────┬───────────────┘
               │
               ▼
     ┌──────────────────┐
     │  SwiftData Store │
     │  (SQLite)        │
     └──────────────────┘
```

---

## 🎯 Build Requirements

### **Xcode Settings**
1. **Signing & Capabilities** → Add "Family Controls"
2. **General** → Deployment Info → iPhone only, Portrait
3. **Paid Apple Developer account** (Family Controls requires it)

### **Info.plist**
- `NSUserNotificationsUsageDescription` - Already configured
- `NSFamilyControlsUsageDescription` - Already configured

---

## ✅ Checklist Before Building

- [ ] All 10 new files added to Xcode project
- [ ] Old deleted files removed from Xcode (red references)
- [ ] "Family Controls" capability added
- [ ] Paid developer team selected for signing
- [ ] Real iPhone connected (not Simulator)
- [ ] Clean build folder: `Cmd + Shift + K`
- [ ] Build: `Cmd + B`

---

## 🐛 Common Issues

### **"Cannot find BlockingSchedule"**
→ New files not added to Xcode. See SETUP_CHECKLIST.md

### **"Personal Team doesn't support Family Controls"**
→ Switch to paid Apple Developer team in Signing

### **"Screen Time not working"**
→ Must test on real device, not Simulator

### **Build errors after adding files**
→ Clean build folder (`Cmd + Shift + K`) and rebuild

---

## 📚 Key Files to Review

1. **Start here:** `focusApp.swift` - App entry
2. **Main flow:** `MainAppView.swift` → `HomeView.swift`
3. **Scheduling logic:** `ScheduleService.swift`
4. **Screen Time:** `ScreenTimeService.swift`
5. **Data models:** `Models/BlockingSchedule.swift`

---

**This app is ready to build and run!** 🚀

