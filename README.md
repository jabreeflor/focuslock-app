# 🔒 FocusLock

> **"Break the Lock, If You Can."**

FocusLock is an iOS app that blocks distracting apps during scheduled focus sessions. Want to check Instagram during work hours? Solve a math problem, word puzzle, or logic challenge first. The harder the difficulty, the longer it takes — making impulse scrolling not worth it.

## Why FocusLock?

Apple's Screen Time is too easy to bypass — a single tap on "Ignore Limit" defeats the purpose. FocusLock adds **real friction** that scales with intentionality:

- 🟢 **Easy** — Simple math (~10s) → 5 min unlock
- 🟡 **Medium** — Word problems & patterns (~30-60s) → 10 min unlock
- 🔴 **Hard** — Logic puzzles & long typing (2-5 min) → 15 min unlock

## Features

### 🛡️ Smart App Blocking
- Block any app using Apple's Screen Time API (FamilyControls / ManagedSettings)
- Custom shield screen appears when you try to open blocked apps
- Persists through force-quit — no easy bypass

### 🧩 Challenge Engine
- **Math challenges** — arithmetic problems scaled by difficulty
- **Typing challenges** — type passages accurately
- **Pattern matching** — complete visual or logical sequences
- **Strict Mode** — difficulty escalates with each consecutive unlock attempt

### 📅 Flexible Scheduling
- Recurring schedules (e.g., Mon–Fri 9am–5pm)
- One-time focus sessions with custom duration
- Per-schedule app selection and difficulty settings

### 📊 Focus Analytics
- Daily/weekly/monthly focus time tracking
- Streak counter with weekly summaries
- Unlock attempt breakdown (completed vs. gave up)
- Most-blocked app rankings

## Architecture

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Data | SwiftData |
| Screen Time | FamilyControls, ManagedSettings, DeviceActivity |
| Charts | Swift Charts |
| Target | iOS 17.0+ |

```
FocusLock/
├── App/                    # App entry point
├── Features/
│   ├── Onboarding/         # First-run setup flow
│   ├── Home/               # Dashboard & quick start
│   ├── Schedule/           # CRUD for focus schedules
│   ├── Challenge/          # Challenge UI & providers
│   ├── Stats/              # Analytics & charts
│   └── Settings/           # Preferences & config
├── Models/                 # SwiftData models
├── Services/               # Business logic layer
├── Extensions/             # Screen Time extensions
└── Shared/                 # Reusable components & theme
```

## Docs

- [Product Requirements Document](docs/PRD.md)
- [BDD Test Scenarios](docs/BDD-Scenarios.md)

## License

MIT
