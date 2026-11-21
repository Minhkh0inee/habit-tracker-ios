# Momentum

A minimalist, high-contrast iOS Habit & Technical Learning Tracker built natively with **SwiftUI**, **SwiftData**, **WidgetKit**, and backed by **Supabase Auth & Cloud Backend**, featuring an elegant monochrome Bento design system. Designed specifically for software engineers, computer science students, and self-directed learners pursuing deep work and interview mastery.

![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-black?style=flat-square&logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square&logo=swift)
![SwiftData](https://img.shields.io/badge/SwiftData-Local%20Persistence-blue?style=flat-square)
![Supabase](https://img.shields.io/badge/Backend-Supabase%20Cloud-3ECF8E?style=flat-square&logo=supabase)
![WidgetKit](https://img.shields.io/badge/WidgetKit-Home%20%26%20Lock%20Screen-purple?style=flat-square)
![Security](https://img.shields.io/badge/Security-iOS%20Keychain-red?style=flat-square)
![Testing](https://img.shields.io/badge/XCTest-850%2B%20LOC%20Unit%20Tests-brightgreen?style=flat-square)

---

## 🎬 App Demo

[![Watch Demo Video](https://img.shields.io/badge/Demo-Watch%20Video-E50914?style=for-the-badge&logo=google-drive&logoColor=white)](https://drive.google.com/file/d/1OSeYZnh4t7RuU1EGovaoMhHJvVoyUC2W/view?usp=drive_link)

> 📹 **Walkthrough Video**: [Watch the Momentum App Demo on Google Drive](https://drive.google.com/file/d/1OSeYZnh4t7RuU1EGovaoMhHJvVoyUC2W/view?usp=drive_link)
>
> An end-to-end video walkthrough showcasing the monochrome Bento dashboard, Duolingo-style streak heat tiers, focus timer with photo proof verification, daily goals workflow, Leitner SRS interview recall, and WidgetKit Home/Lock screen integration.

---

## 🌟 Key Highlights & Features

### 🔐 Supabase Cloud Authentication & User Management
- **Sign in with Apple (Native)**: Full biometric / Apple ID authentication flow using `CryptoKit` SHA256 nonce hashing and `AuthenticationServices` (`ASAuthorizationAppleIDCredential`).
- **Email & Password Authentication**: Seamless sign-up, sign-in, and session persistence backed by Supabase Auth with real-time `authStateChanges` event stream listener.
- **Hierarchical Secrets Resolution**: Robust `SupabaseConfig` resolving credentials safely across untracked `Secrets.plist`, `Info.plist`, and environment variables.

### 🔥 Duolingo-Style Streak Engine & Grace Period
- **Stateless Mathematical Engine**: Computes current and all-time longest consecutive-day streaks from session dates with zero database coupling (`StreakEngine`).
- **Dynamic Heat Tiers**: Escalating visual feedback across 4 flame stages: *Building (1–6d)*, *Hot (7–13d)*, *Blazing (14–29d)*, and *Legendary (30+d)*.
- **Urgency & Loss Aversion**: Detects `isAtRisk` state when yesterday was completed but today is pending, dynamically switching UI cues (ice/snowflake theme) and scheduling smart evening retention push alerts.
- **Grace Day Architecture**: Built-in 1-day pardon challenge mechanism to salvage broken streaks without breaking rhythm.

### 📱 WidgetKit Home & Lock Screen Extension
- **Multi-Family Support**: Full support for `.systemSmall`, `.systemMedium`, and iOS Lock Screen accessories (`.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline`).
- **Decoupled Snapshot IPC**: Dedicated `StreakWidgetSnapshotService` communicating across targets via **App Groups** (`group.com.habittracker.app`) and a shared `UserDefaults` suite. Eliminates database file locking and keeps the widget memory footprint near zero.
- **Deep Linking**: Direct URL routing (`habittracker://streak`) from Home Screen tap directly into relevant app flows.

### 🎯 Split Daily Goals vs Full Syllabus Architecture
- **Today's Goals Sheet (`TodayGoalsSheet`)**: Accessible by tapping any habit card on the Today screen. Displays today's scheduled concepts with an animated daily goal progress bar (`X of Y Tasks Done`), expandable content cards revealing concept notes, and a one-tap focus timer launcher.
- **Full Syllabus & Roadmap Screen (`HabitCurriculumSheet`)**: Accessible from the Habit Mastery & Process view. Provides high-level visibility across learning roadmaps with milestone mastery percentages, AI-assisted syllabus generator, and concept backlogs.

### 🧠 Spaced Repetition System (SRS) — Leitner Engine
- **Memory Retention Curve**: 5-stage Leitner spaced repetition interval scheduler ($1\text{d} \to 3\text{d} \to 7\text{d} \to 14\text{d} \to 30\text{d} \to 60\text{d}$).
- **Interview Recall Flashcards**: Interactive revision mode with self-grading (*"Hard / Reset"* vs *"Nailed It! / Advance"*) specifically targeted at engineering concepts and system design trade-offs.

### ⏱️ Focus Timer & Photo Proof
- **Background-Resilient Timer**: Anchored with timestamp offsets rather than fragile ticks so timers survive backgrounding, app suspensions, and device locks.
- **Photo Verification**: Completed sessions record visual proof via physical camera with fallback to local photo library stored safely in local sandboxed storage (`Documents/Proofs/`).
- **Completed Card State**: Completed habit cards instantly turn solid green with high-contrast white typography, collapsing daily previews for a clean, rewarding dashboard.

### 🔐 Hardware-Backed Security (Keychain Integration)
- **Zero Plain-Text Secrets**: Replaced standard `UserDefaults` storage with an in-house wrapper around Apple's `Security.framework` (`SecItemAdd`, `SecItemCopyMatching`, `SecItemDelete`) using `kSecClassGenericPassword` and `kSecAttrAccessibleAfterFirstUnlock`.
- **Seamless Migration**: Backward-compatible automatic migration pipeline that detects, migrates, and purges legacy keys from disk.

---

## 🏗️ Architecture & Project Structure

```
Momentum (HabitTracker)
 ├── Core/
 │    └── Configuration/ # SupabaseConfig (Secrets resolution)
 ├── Models/             # SwiftData Models (@Model) with cascade deletion rules
 │    ├── Habit.swift
 │    ├── HabitSession.swift
 │    ├── CurriculumConcept.swift
 │    ├── CurriculumSeedData.swift
 │    └── LessonItem.swift
 ├── ViewModels/         # Observable MVVM state containers
 ├── Views/              # SwiftUI Views styled with Bento design system
 │    ├── Auth/          # LoginView, SignUpView, AuthRootView
 │    ├── Today/         # TodayHabitsView, HabitCardView, TodayGoalsSheet, EditHabitSheet
 │    ├── Progress/      # HabitProgressView, InterviewRecallView
 │    ├── Timer/         # TimerView, SessionCompletionSheet, CircularProgressView
 │    └── Common/        # HabitCurriculumSheet, UIComponents, SplashScreenView
 ├── Services/
 │    ├── Supabase/      # SupabaseClientManager, SupabaseAuthService
 │    ├── StreakEngine.swift              # Pure stateless streak algorithms
 │    ├── SpacedRepetitionScheduler.swift # Leitner SRS interval calculator
 │    ├── KeychainService.swift          # Hardware-backed Security.framework wrapper
 │    ├── NotificationManager.swift      # UserNotifications with evening at-risk alerts
 │    ├── GeminiSyncService.swift        # AI prompt pipeline via URLSession
 │    └── ImageStorageService.swift      # Local disk sandboxed photo persistence
 └── Services/Snapshot/                  # Bridges app state to App Group shared container
      │
      └───► App Group Container (group.com.habittracker.app)
                  │
                  ▼
Momentum Widget (HabitTrackerWidget)
 ├── StreakWidget.swift                  # Small, Medium & Lock Screen timeline views
 └── StreakTimelineProvider.swift        # Proactive widget reload scheduling
```

- **Language**: Swift 6 (Strict Concurrency ready)
- **UI Framework**: SwiftUI
- **Local Persistence**: SwiftData (`Habit`, `HabitSession`, `LessonItem`, `InterviewQuestion`, `CurriculumConcept`)
- **Cloud Backend & Auth**: Supabase (`supabase-swift`), Sign in with Apple (`AuthenticationServices`)
- **Widget Target**: WidgetKit + App Groups
- **Security**: Apple `Security.framework` (Keychain Services)
- **Data Visualization**: Apple Charts (`AreaMark`, `LineMark`, `PointMark`)
- **System Services**: `UserNotifications`, `AVFoundation`
- **Networking**: Native `URLSession` with `MockURLProtocol` test harness

---

## 🧪 Comprehensive Unit Testing (XCTest)

The project includes **850+ lines of comprehensive unit tests** verifying core logic, persistence, and edge cases:

- `SupabaseAuthServiceTests`: Async mock testing of authentication states, token refresh, and sign-out logic.
- `StreakEngineTests`: Boundary checks, 0-session states, intra-day multi-session deduplication, streak tier transitions, and midnight rollovers.
- `SpacedRepetitionSchedulerTests`: Exact validation of Leitner date calculations and stage resets.
- `KeychainServiceTests`: Secure round-trip verification (save, load, update, delete).
- `GeminiSyncServiceTests`: Network mocked via custom `MockURLProtocol` ensuring complete test coverage without live API dependency.
- `HabitModelPersistenceTests`: In-memory SwiftData container relationship integrity and cascade deletions.
- `TimerViewModelTests`: State machine transitions (`idle` $\to$ `running` $\to$ `paused` $\to$ `completed`).
- `ImageStorageServiceTests`: Sandboxed file creation, read verification, and clean disk deletion.

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0+
- Xcode 16.0+
- iOS 17.0+ Simulator or Physical Device
- Supabase account (free tier)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Minhkh0inee/habit-tracker-ios.git
   cd habit-tracker-ios
   ```

2. Open the project in Xcode:
   ```bash
   open HabitTracker.xcodeproj
   ```

3. Configure Supabase Credentials:
   - Create a `Secrets.plist` file in the project (or set environment variables):
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
         <key>SUPABASE_URL</key>
         <string>https://your-project-id.supabase.co</string>
         <key>SUPABASE_ANON_KEY</key>
         <string>your-anon-key</string>
     </dict>
     </plist>
     ```

4. Ensure both the **HabitTracker** and **HabitTrackerWidget** targets have their Signing Team set under **Signing & Capabilities**. Both share the App Group `group.com.habittracker.app`.

5. Select the **HabitTracker** scheme and press **`Cmd + R`** to run **Momentum** on simulator or device.

6. To execute the full unit test suite, press **`Cmd + U`**.

---

## 📄 License

Distributed under the MIT License. Feel free to use and customize for your own learning projects!
