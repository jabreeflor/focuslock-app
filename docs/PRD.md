# FocusLock — Product Requirements Document

> **"Break the Lock, If You Can."**

---

## Overview

| | |
|---|---|
| **App Name** | FocusLock |
| **Tagline** | Break the Lock, If You Can |
| **Platform** | iOS 17+ |
| **Version** | 1.0 (MVP) |
| **Status** | Planning |
| **Created** | 2026-02-28 |

### Elevator Pitch

FocusLock blocks distracting apps during scheduled focus sessions. Want to check Instagram during work hours? You'll need to solve a math problem, word puzzle, or complex logic challenge first. The harder the difficulty, the longer it takes — making impulse scrolling not worth it. Track your focus streaks, see how many times you resisted, and build real discipline.

### Target Audience

- **Knowledge workers** who need deep focus blocks during the workday
- **Students** preparing for exams who can't stop opening TikTok
- **Screen time reducers** who find Apple's built-in tools too easy to bypass (one tap dismiss)
- **Gamification lovers** who enjoy streaks and stats
- **Ages 16–35**, iPhone users aware of their screen time problem

### Alternative Name Ideas

- **MindGate** — unlock with your mind
- **LockSmith** — puzzle your way out
- **FocusWall** — build a wall around distractions

*(Sticking with FocusLock for now — clear, memorable, descriptive)*

---

## Problem Statement

Apple's Screen Time is too easy to bypass — a single tap on "Ignore Limit" defeats the purpose. Users need **friction** that scales with intentionality. If you *really* need an app, you can earn access by solving a challenge. If you're just impulse-checking, the friction makes you give up.

---

## User Stories

### Onboarding
- **US-1**: As a new user, I want a quick onboarding flow that explains how FocusLock works so I can set it up in under 2 minutes.
- **US-2**: As a new user, I want to select which apps to block so I only restrict distracting ones.
- **US-3**: As a new user, I want to choose my default difficulty level so challenges match my preference.

### Scheduling
- **US-4**: As a user, I want to create recurring schedules (e.g., Mon-Fri 9am-5pm) so blocking happens automatically.
- **US-5**: As a user, I want to create one-time focus sessions with a custom duration so I can do ad-hoc deep work.
- **US-6**: As a user, I want to see all my active and upcoming schedules in one view.
- **US-7**: As a user, I want to pause a schedule temporarily without deleting it.

### App Locking
- **US-8**: As a user, I want blocked apps to show a lock screen when I try to open them during a focus session.
- **US-9**: As a user, I want the lock to persist even if I force-quit and reopen the app.
- **US-10**: As a user, I want to add or remove apps from my block list at any time (outside active sessions).

### Unlock Challenges
- **US-11**: As a user, I want to solve a challenge to unlock an app early so there's friction but not impossibility.
- **US-12**: As a user, I want Easy challenges (simple arithmetic) that take ~10 seconds.
- **US-13**: As a user, I want Medium challenges (word problems, pattern matching) that take ~30-60 seconds.
- **US-14**: As a user, I want Hard challenges (logic puzzles, long-form typing) that take 2-5 minutes.
- **US-15**: As a user, I want the unlock to be temporary (5-15 min based on difficulty) so I can't just unlock once and scroll forever.
- **US-16**: As a user, I want a "Give Up" option that logs my attempt but keeps the app locked, reinforcing discipline.

### Stats & Dashboard
- **US-17**: As a user, I want to see my total focus time today/this week/this month.
- **US-18**: As a user, I want to see my current streak (consecutive days with completed focus sessions).
- **US-19**: As a user, I want to see how many unlock attempts I made and how many I completed vs. gave up.
- **US-20**: As a user, I want to see which apps I tried to open most during focus sessions.
- **US-21**: As a user, I want weekly summary notifications showing my focus stats.

### Settings
- **US-22**: As a user, I want to set a master difficulty level or per-app difficulty.
- **US-23**: As a user, I want to enable/disable notifications for session start/end.
- **US-24**: As a user, I want to set unlock duration (how long an app stays unlocked after solving a challenge).
- **US-25**: As a user, I want to enable "Strict Mode" where challenges get harder with each consecutive unlock attempt.

---

## Feature Breakdown

### 1. Screen Lock Service
**Priority:** P0 (Core)

Uses Apple's **Screen Time API** (`FamilyControls` / `ManagedSettings` / `DeviceActivity` frameworks) to:
- Request Screen Time authorization from the user
- Apply app restrictions via `ManagedSettingsStore`
- Monitor app launches via `DeviceActivityMonitor`
- Show a custom shield (lock screen) when a blocked app is opened

**Technical Notes:**
- Requires `FamilyControls` entitlement (available to all developers since iOS 16)
- Shield UI is rendered via `ShieldConfigurationExtension`
- App restrictions managed via `ManagedSettingsStore.shield`
- DeviceActivity extensions run in separate processes

### 2. Challenge Engine
**Priority:** P0 (Core)

A modular system that generates and validates challenges:

| Difficulty | Type | Time to Solve | Unlock Duration |
|---|---|---|---|
| Easy | Simple math (e.g., 47 + 38 = ?) | ~10s | 5 min |
| Easy | Quick typing (type a short sentence) | ~15s | 5 min |
| Medium | Word problems | ~30-60s | 10 min |
| Medium | Pattern completion | ~30s | 10 min |
| Medium | Multi-step math | ~45s | 10 min |
| Hard | Logic puzzles (e.g., Sudoku fragment) | 2-3 min | 15 min |
| Hard | Long passage typing (no errors) | 3-5 min | 15 min |
| Hard | Sequence/cipher decoding | 2-4 min | 15 min |

**Architecture:**
```
ChallengeEngine (Protocol)
├── MathChallengeProvider
├── TypingChallengeProvider
├── WordProblemProvider
├── PatternProvider
├── LogicPuzzleProvider
└── CipherProvider
```

Each provider conforms to `ChallengeProvider`:
```swift
protocol ChallengeProvider {
    var difficulty: Difficulty { get }
    func generate() -> Challenge
    func validate(answer: String, for challenge: Challenge) -> Bool
}
```

### 3. Scheduling System
**Priority:** P0 (Core)

- Recurring schedules stored in local persistence (SwiftData)
- One-time sessions with countdown timer
- Integration with `DeviceActivitySchedule` for system-level enforcement
- Calendar-style view for managing schedules

**Data Model:**
```swift
@Model class FocusSchedule {
    var id: UUID
    var name: String
    var blockedApps: [AppToken]
    var daysOfWeek: Set<DayOfWeek>  // for recurring
    var startTime: DateComponents
    var endTime: DateComponents
    var isRecurring: Bool
    var isActive: Bool
    var difficulty: Difficulty
    var createdAt: Date
}
```

### 4. Stats Dashboard
**Priority:** P1

- Focus time tracking (per day, week, month)
- Streak calculation (consecutive days with ≥1 completed session)
- Unlock attempt logging (attempted, completed, gave up)
- Most-blocked app rankings
- Weekly summary via local notifications
- Charts via Swift Charts framework

### 5. Onboarding
**Priority:** P1

3-4 screen flow:
1. Welcome + value prop
2. Screen Time permission request
3. Select apps to block
4. Choose default difficulty + create first schedule

### 6. Notifications
**Priority:** P2

- Session starting soon (5 min before)
- Session ended
- Streak milestone (7 days, 30 days, etc.)
- Weekly summary

---

## Technical Architecture

### Stack
| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Navigation | NavigationStack |
| Data | SwiftData |
| Screen Time | FamilyControls, ManagedSettings, DeviceActivity |
| Charts | Swift Charts |
| Notifications | UserNotifications |
| Min Target | iOS 17.0 |

### App Structure
```
FocusLock/
├── App/
│   ├── FocusLockApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Schedule/
│   │   ├── ScheduleListView.swift
│   │   ├── CreateScheduleView.swift
│   │   └── ScheduleViewModel.swift
│   ├── Challenge/
│   │   ├── ChallengeView.swift
│   │   ├── ChallengeViewModel.swift
│   │   └── Providers/
│   │       ├── MathChallengeProvider.swift
│   │       ├── TypingChallengeProvider.swift
│   │       ├── WordProblemProvider.swift
│   │       ├── PatternProvider.swift
│   │       └── LogicPuzzleProvider.swift
│   ├── Stats/
│   │   ├── StatsView.swift
│   │   ├── StatsViewModel.swift
│   │   └── Charts/
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Models/
│   ├── FocusSchedule.swift
│   ├── Challenge.swift
│   ├── UnlockAttempt.swift
│   └── FocusSession.swift
├── Services/
│   ├── ScreenTimeService.swift
│   ├── ChallengeEngine.swift
│   ├── ScheduleManager.swift
│   ├── StatsService.swift
│   └── NotificationService.swift
├── Extensions/
│   ├── ShieldConfigurationExtension/
│   └── DeviceActivityMonitorExtension/
└── Shared/
    ├── Components/
    ├── Theme/
    └── Utilities/
```

### Key Extensions (separate targets)
1. **ShieldConfigurationExtension** — renders the custom lock screen with challenge UI
2. **DeviceActivityMonitorExtension** — monitors schedule intervals, applies/removes shields

---

## Screen Descriptions

### 1. Home Screen
- Current focus session status (active/inactive)
- Quick-start button for ad-hoc sessions
- Today's stats summary (focus time, attempts blocked)
- Next scheduled session preview
- Tab bar: Home | Schedules | Stats | Settings

### 2. Schedule List
- List of all schedules (active highlighted)
- Each row: name, days, time range, app count, difficulty badge
- Swipe to delete/pause
- FAB or "+" to create new schedule

### 3. Create/Edit Schedule
- Schedule name input
- App picker (uses FamilyControls picker)
- Day selector (M T W T F S S toggles)
- Start/end time pickers
- Difficulty selector (Easy/Medium/Hard segmented control)
- Save button

### 4. Lock Screen (Shield)
- App icon (blurred) with lock overlay
- "This app is locked until [time]"
- "Solve a challenge to unlock for [X] minutes"
- Difficulty badge
- "Start Challenge" button
- "Give Up" button (subtle, secondary)

### 5. Challenge Screen
- Challenge prompt (math equation, typing passage, puzzle grid)
- Input field or interactive element
- Timer showing elapsed time
- Submit button
- On success: "Unlocked for X minutes!" with countdown
- On failure: "Try again" with new challenge

### 6. Stats Dashboard
- Focus time chart (bar chart, past 7 days)
- Current streak with flame icon
- Total focus hours (all time)
- Unlock attempts: pie chart (completed vs gave up)
- Most blocked apps list (top 5)
- "This Week vs Last Week" comparison

### 7. Settings
- Default difficulty selector
- Unlock duration per difficulty
- Strict Mode toggle (escalating difficulty)
- Notification preferences
- Screen Time permissions status
- App version / support links

### 8. Onboarding (4 screens)
1. **Welcome**: App icon, tagline, "Get Started" CTA
2. **How It Works**: 3-step illustration (Block → Challenge → Focus)
3. **Permissions**: Screen Time authorization request
4. **Setup**: Quick app selection + first schedule creation

---

## Design System

### Colors
| Token | Light | Dark | Usage |
|---|---|---|---|
| Primary | #4F46E5 (Indigo 600) | #818CF8 (Indigo 400) | CTAs, active states |
| Secondary | #0EA5E9 (Sky 500) | #38BDF8 (Sky 400) | Accents, links |
| Success | #22C55E (Green 500) | #4ADE80 (Green 400) | Completed, unlocked |
| Warning | #F59E0B (Amber 500) | #FBBF24 (Amber 400) | Streaks, caution |
| Danger | #EF4444 (Red 500) | #F87171 (Red 400) | Locked, failed |
| Surface | #F8FAFC | #1E293B | Card backgrounds |
| Background | #FFFFFF | #0F172A | Screen backgrounds |

### Typography
- **Title**: SF Pro Display Bold, 28pt
- **Heading**: SF Pro Display Semibold, 22pt
- **Subheading**: SF Pro Text Medium, 17pt
- **Body**: SF Pro Text Regular, 15pt
- **Caption**: SF Pro Text Regular, 13pt

### Iconography
- SF Symbols throughout
- Key icons: `lock.fill`, `lock.open.fill`, `brain.head.profile`, `chart.bar.fill`, `calendar`, `flame.fill`, `puzzlepiece.fill`

### Spacing
- 4pt grid system
- Standard padding: 16pt
- Card padding: 20pt
- Section spacing: 24pt

### Components
- **DifficultyBadge**: Capsule with color (Green/Amber/Red) and label
- **FocusCard**: Rounded rect (16pt radius) with shadow, used on Home
- **StreakCounter**: Flame icon + number, animated on milestone
- **ChallengeTimer**: Circular progress ring
- **AppPill**: Small rounded chip with app icon + name

---

## MVP Scope (v1.0)

### In Scope
- Screen Time API integration (block/unblock)
- 3 challenge types: math, typing, pattern matching
- Recurring + one-time schedules
- Basic stats (focus time, streaks, attempt count)
- Onboarding flow
- Local data only (no accounts/sync)

### Out of Scope (Future)
- Social features (compete with friends)
- Custom challenge creation
- Widget support
- Apple Watch companion
- Cloud sync / multi-device
- AI-generated challenges
- Accountability partner mode

---

## Success Metrics

| Metric | Target |
|---|---|
| Daily Active Users | 1,000 in first month |
| Avg Focus Time / Day | ≥ 2 hours |
| Challenge Give-Up Rate | ≥ 60% (friction is working) |
| 7-Day Retention | ≥ 40% |
| App Store Rating | ≥ 4.5 |

---

## Timeline (Estimated)

| Phase | Duration | Deliverables |
|---|---|---|
| Scaffold + Core Models | 1 week | Project setup, data models, navigation |
| Screen Time Integration | 2 weeks | FamilyControls, shield, monitor |
| Challenge Engine | 1.5 weeks | 3 challenge types, validation |
| Scheduling System | 1 week | CRUD, recurring logic, DeviceActivity |
| Stats Dashboard | 1 week | Charts, streak calc, tracking |
| Onboarding + Polish | 1 week | Onboarding flow, animations, edge cases |
| Testing + Launch | 1 week | TestFlight, bug fixes, App Store submission |
| **Total** | **~8.5 weeks** | |
