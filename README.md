# FocusLock — iOS App

Deep work timer that helps you block distractions and stay in flow states.

## Requirements

- Xcode 16+
- iOS 17+ deployment target
- Swift 5.9+
- macOS 14+ (for building)

## Setup

```bash
# Clone the repo
git clone https://github.com/jabreeflor/focuslock-app
cd focuslock-app

# Open in Xcode
open FocusLock.xcodeproj

# Build + run on simulator
# Product → Run (⌘R)
# Target: iPhone 17 Pro (or any iOS 17+ simulator)
```

## Dependencies

All dependencies are managed via Swift Package Manager (no CocoaPods or Carthage).

- **RevenueCat** — Subscription/paywall management (see `REVENUCAT-INTEGRATION.md`)

## Project Structure

```
FocusLock/
├── App/                    # App entry point, app delegate
├── Views/                  # SwiftUI views
│   ├── Timer/             # Main timer screen
│   ├── History/           # Session history + stats
│   ├── Settings/          # User preferences
│   └── Paywall/           # Pro upgrade screen
├── Models/                # Data models, session logic
├── Services/              # Timer engine, notification service
├── Extensions/            # Swift extensions
└── Assets.xcassets/       # Images, colors, app icon
```

## App Store Submission Checklist

- [x] App compiles on iPhone 17 Pro simulator
- [x] App icon at 1024×1024 (no alpha channel)
- [x] App Store description written (`app-store/description.md`)
- [x] ASO keywords prepared (`app-store/keywords.txt`)
- [ ] Screenshots captured (needs Apple Dev account in Simulator)
- [ ] RevenueCat products configured (needs App Store Connect)
- [ ] TestFlight build uploaded (needs Apple Dev credentials)
- [ ] Privacy policy URL added (required)
- [ ] App Review Notes written

## RevenueCat Setup

See `REVENUCAT-INTEGRATION.md` for full setup instructions.

Pricing:
- FocusLock Pro Monthly: $3.99/mo
- FocusLock Pro Annual: $29.99/yr (save 37%)

## Building for Release

```bash
# In Xcode:
# 1. Set scheme to "FocusLock" (not a test target)
# 2. Set destination to "Any iOS Device (arm64)"
# 3. Product → Archive
# 4. Distribute App → App Store Connect
```
