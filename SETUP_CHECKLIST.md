# 🚀 Quick Setup Checklist

Follow these steps to get your refactored app running:

---

## ✅ Step 1: Add New Files to Xcode

**IMPORTANT:** The new files exist in your filesystem but aren't registered in Xcode yet!

### **In Xcode:**

1. **Open your project** in Xcode
2. In the **Project Navigator** (left sidebar), **right-click** on the `focus` folder
3. Select **"Add Files to 'focus'..."**
4. Navigate to your project folder and select these 10 files:

### **Models** (in `focus/Models/`)
- ☐ `BlockingSchedule.swift`
- ☐ `UsageAttempt.swift`
- ☐ `OverrideSession.swift`

### **Services** (in `focus/Services/`)
- ☐ `ScheduleService.swift`
- ☐ `UsageTrackingService.swift`

### **Views** (in `focus/Views/`)
- ☐ `HomeView.swift`
- ☐ `ScheduleEditorView.swift`
- ☐ `ChallengeView.swift`
- ☐ `NewOnboardingView.swift`
- ☐ `MainAppView.swift`

5. **IMPORTANT:** Make sure **"Copy items if needed" is UNCHECKED** ✗
6. Make sure your **target is selected** ✓
7. Click **"Add"**

---

## ✅ Step 2: Clean and Build

1. **Clean Build Folder:** Press `Cmd + Shift + K` (or Product → Clean Build Folder)
2. **Build:** Press `Cmd + B` (or Product → Build)
3. **Fix any import errors** that appear (Xcode should suggest fixes)

---

## ✅ Step 3: Test on Device

Screen Time API has limited functionality in the Simulator. **Test on a real iPhone!**

1. Connect your iPhone
2. Select it as the target device
3. Run the app: `Cmd + R`

---

## ✅ Step 4: Go Through Onboarding

The new onboarding will guide you through:
1. Welcome screen
2. Enable notifications
3. Grant Screen Time access
4. Select apps to block
5. Create your first schedule

**Quick presets available:**
- Work Hours (9 AM - 5 PM, Mon-Fri)
- Sleep Time (10 PM - 7 AM, Daily)
- Or create custom

---

## ✅ Step 5: Test Features

### **Schedule Blocking:**
- ☐ Create a test schedule (e.g., next 5 minutes)
- ☐ Wait for blocking to activate
- ☐ Try to open a blocked app
- ☐ See shield screen

### **Challenge System:**
- ☐ While blocking is active, tap "Solve Challenge to Unlock"
- ☐ Complete the math puzzle
- ☐ Get 5-minute override
- ☐ Verify apps are accessible

### **Streak:**
- ☐ Check streak counter on home screen
- ☐ Verify it resets after using override

---

## 🗑️ Step 6: Optional Cleanup

Once everything works, you can **delete** these old files:

### **No longer used:**
- `Views/FocusSessionView.swift` (replaced by HomeView)
- `Views/ActiveSessionView.swift` (timer-based)
- `Views/SessionHistoryView.swift` (old history)
- `Views/OnboardingView.swift` (replaced by NewOnboardingView)
- `ViewModels/FocusSessionViewModel.swift` (old logic)
- `Services/TimerService.swift` (no longer needed)

### **Keep for now:**
- `Models/FocusSession.swift` (database compatibility)

**To delete:**
1. Right-click file in Xcode
2. Select "Delete"
3. Choose "Move to Trash"

---

## 🐛 Troubleshooting

### **"Cannot find type 'BlockingSchedule' in scope"**
→ You forgot to add the new files to Xcode (Step 1)

### **"Screen Time not working in Simulator"**
→ Screen Time API requires a real device (Step 3)

### **"SourceKit error" in Xcode**
→ Xcode's cache is confused. Clean build folder and rebuild.

### **App crashes on launch**
→ Check the console for SwiftData errors. You may need to delete and reinstall the app to reset the database.

### **Blocking doesn't activate**
→ Make sure:
1. Screen Time permission is granted
2. Apps are selected
3. Schedule is enabled (toggle switch on)
4. Current time is within schedule range

---

## 📚 Need Help?

- Read `REFACTOR_GUIDE.md` for detailed architecture
- Check console logs (Xcode bottom panel) for debugging info
- Look for emoji logs: 🔒 (blocking), 🔓 (unblocked), ✅ (success)

---

## 🎉 You're Done!

Your app is now a **schedule-based app blocker** with:
- ✅ Recurring schedules
- ✅ Challenge system
- ✅ Streak tracking
- ✅ Usage stats
- ✅ Smart notifications

Enjoy! 🚀

