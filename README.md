# HabitTracker iOS

A minimalist, privacy-focused iOS Habit Tracker built natively in **SwiftUI** and **SwiftData** with an elegant monochrome design. Designed specifically for software engineers, computer science students, and lifelong learners tracking technical study habits.

![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-black?style=flat-square&logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square&logo=swift)
![SwiftData](https://img.shields.io/badge/SwiftData-Local%20Persistence-blue?style=flat-square)
![Zero 3rd Party](https://img.shields.io/badge/Dependencies-Zero%20External-green?style=flat-square)

---

## Key Features

- **Countdown Focus Timer**: Built-in presets (15m, 25m, 45m, 60m) with background-safe timestamp anchoring.
- **Photo Proof Verification**: Visual proof of completion (camera on physical iPhone; photo library fallback in Simulator).
- **Itemized Concept & Spaced Repetition**: Dynamic post-session concept entries backed by Leitner curve spaced repetition ($1\text{d} \to 3\text{d} \to 7\text{d} \to 14\text{d} \to 30\text{d}$).
- **Gemini 2.5 Flash AI Question Sync**: Multi-select track selector to fetch real-world interview questions dynamically into your local bank.
- **Interactive Calendar & Proof Gallery**: Collapsible date feeds with full-resolution proof inspections.
- **Native Apple Charts**: 7-day and 14-day study trend visualization.
- **Daily Reminders**: 5:00 AM local notification with interactive testing.
- **Offline First**: All habits, photos, and sessions persist in local SwiftData storage without cloud dependency.

---

## Tech Stack & Architecture

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData (`Habit`, `HabitSession`, `LessonItem`, `InterviewQuestion`)
- **Data Visualization**: Apple Charts
- **Notifications**: `UserNotifications`
- **AI Integration**: Gemini 2.5 Flash API via native `URLSession`

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Minhkh0inee/habit-tracker-ios.git
   cd habit-tracker-ios
   ```

2. Open in Xcode:
   ```bash
   open HabitTracker.xcodeproj
   ```

3. Select your target device (e.g., **iPhone 16 Pro Simulator** or physical device) and press **`Cmd + R`** to run.

For physical device signing instructions via free Apple ID Personal Team, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

---

## License

MIT License. Free to use and customize.
