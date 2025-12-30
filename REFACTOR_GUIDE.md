# Focus App Refactor Guide

## 🎯 Major Changes

The app has been **completely refactored** from a **session-based focus timer** to a **schedule-based app blocker**.

---

## 📋 What Changed

### **OLD MODEL: Focus Timer**
- User manually starts/stops focus sessions
- Apps blocked only during active session
- Track completed sessions
- Streak based on completed sessions

### **NEW MODEL: Scheduled Blocker**
- User creates blocking schedules (e.g., "9am-5pm Mon-Fri")
- Apps auto-block/unblock based on schedule
- Challenge system to temporarily override blocking
- Streak based on days WITHOUT using overrides
- Track app open attempts (blocked vs override)

---

## 📁 New Files Created

### **Models**
- `BlockingSchedule.swift` - Recurring schedule for when apps are blocked
- `UsageAttempt.swift` - Log of app open attempts
- `OverrideSession.swift` - Temporary override after completing challenge

### **Services**
- `ScheduleService.swift` - Manages schedules and blocking state
- `UsageTrackingService.swift` - Tracks app usage attempts (placeholder)

### **Views**
- `HomeView.swift` - **NEW main screen** showing blocking status, stats, schedules
- `ScheduleEditorView.swift` - Create/edit blocking schedules
- `ChallengeView.swift` - Math puzzle to unlock apps temporarily
- `NewOnboardingView.swift` - Updated onboarding for schedules
- `MainAppView.swift` - Wrapper handling onboarding/home

### **Updated Files**
- `focusApp.swift` - Now uses `MainAppView` and registers new models
- `NotificationService.swift` - Schedule-based notifications
- `StreakService.swift` - Streak based on days without overrides

---

## 🚀 How to Add Files to Xcode

**IMPORTANT:** These files were created but need to be added to your Xcode project:

1. **Open Xcode**
2. **Right-click on the `focus` folder** in the Project Navigator
3. **Select "Add Files to 'focus'..."**
4. **Navigate to and select these files:**
   - `Models/BlockingSchedule.swift`
   - `Models/UsageAttempt.swift`
   - `Models/OverrideSession.swift`
   - `Services/ScheduleService.swift`
   - `Services/UsageTrackingService.swift`
   - `Views/HomeView.swift`
   - `Views/ScheduleEditorView.swift`
   - `Views/ChallengeView.swift`
   - `Views/NewOnboardingView.swift`
   - `Views/MainAppView.swift`

5. **Make sure "Copy items if needed" is UNCHECKED** (files are already in the right place)
6. **Make sure your target is selected**
7. **Click "Add"**

8. **Clean Build Folder:**
   - Press `Cmd + Shift + K` (or Product > Clean Build Folder)
   - Then build: `Cmd + B`

---

## 🗑️ Old Files (Can be Deleted Later)

These files are **no longer used** but kept for reference:
- `Views/FocusSessionView.swift` (old main screen)
- `Views/ActiveSessionView.swift` (old timer view)
- `Views/SessionHistoryView.swift` (old history)
- `ViewModels/FocusSessionViewModel.swift` (old view model)
- `Services/TimerService.swift` (old timer logic)
- `Views/OnboardingView.swift` (old onboarding)

**Note:** `FocusSession.swift` model is kept in the database schema for migration purposes.

---

## ✨ New Features

### **1. Schedule Management**
- Create multiple schedules (Work Hours, Sleep Time, etc.)
- Set time ranges and days of week
- Enable/disable schedules
- Quick presets (Work, Sleep, Study)

### **2. Challenge System**
- Math puzzles to temporarily unlock apps
- 5-minute override window
- Breaks streak if used

### **3. Streak System**
- Tracks consecutive days WITHOUT using overrides
- Resets if you solve a challenge and use override
- Motivates discipline over convenience

### **4. Usage Tracking**
- Logs app open attempts
- Shows blocked vs override count
- Recent activity feed
- **Note:** Automatic tracking requires DeviceActivity extension (future work)

### **5. Smart Notifications**
- "Blocking starting" alerts
- "Blocking ended" alerts
- "Override expiring" warnings

---

## 🎨 UI Overview

### **Home Screen**
- **Blocking Status Card** - Shows if blocking is active, which schedule, override button
- **Blocked Apps Card** - Tap to edit app selection
- **Streak Card** - Days without overrides
- **Today's Stats** - Blocks vs overrides count
- **Recent Activity** - Last 5 app attempts
- **Schedules List** - All schedules with toggle switches

### **Onboarding Flow**
1. Welcome
2. Enable Notifications
3. Grant Screen Time Access
4. Select Apps to Block
5. Create First Schedule (presets or custom)

---

## 🔧 How It Works

1. **User creates a schedule** (e.g., "Work Hours: 9am-5pm Mon-Fri")
2. **ScheduleService monitors time** (checks every minute)
3. **When schedule activates:**
   - `ScreenTimeService.applyBlocking()` is called
   - Notification sent: "Blocking active"
4. **If user tries to open blocked app:**
   - System shows shield screen
   - User can tap "Solve Challenge" in app
   - Complete math puzzle → 5-minute override
5. **When schedule ends:**
   - `ScreenTimeService.removeBlocking()` is called
   - Notification sent: "Blocking ended"

---

## 🐛 Known Limitations

### **Usage Tracking**
Currently, usage attempts are **not automatically tracked**. Full implementation requires:
- DeviceActivity framework
- Separate app extension
- Complex setup with `DeviceActivityMonitor`

For now, tracking is manual/simulated. See `UsageTrackingService.swift` for implementation notes.

### **Override Enforcement**
The app **cannot automatically re-enable blocking** after override expires. User must:
- Manually re-enable blocking, OR
- Wait for next schedule to activate

This is a limitation of the Screen Time API.

---

## 🎯 Next Steps

1. **Add files to Xcode** (see instructions above)
2. **Build and test** on a real device (Simulator has limited Screen Time API)
3. **Delete old files** once confirmed working
4. **Optional: Implement DeviceActivity extension** for automatic usage tracking

---

## 📝 Migration Notes

### **Data Migration**
- Old `FocusSession` data is preserved in the database
- New models (`BlockingSchedule`, `UsageAttempt`, `OverrideSession`) are added
- Users will go through onboarding again to set up schedules

### **User Settings**
- `AppSettings.selectedApps` is preserved
- `AppSettings.defaultDuration` is no longer used (kept for compatibility)
- `AppState.hasCompletedOnboarding` is reused

---

## 🎉 Summary

You now have a **schedule-based app blocker** with:
- ✅ Recurring schedules
- ✅ Challenge system for overrides
- ✅ Streak tracking (discipline-focused)
- ✅ Usage stats and activity feed
- ✅ Smart notifications
- ✅ Beautiful paper-themed UI

**Enjoy your new focus app!** 🚀

