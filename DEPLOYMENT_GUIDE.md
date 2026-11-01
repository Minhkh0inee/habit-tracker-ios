# HabitTracker - Local & Physical Device Deployment Guide

This app is built natively in **SwiftUI** and **SwiftData** for iOS 17+. You do **not** need a paid Apple Developer Account (\$99/year) to run this app on your physical iPhone or in the Xcode Simulator.

---

## 1. Quick Launch with Xcode

1. Open Terminal and navigate to the project directory:
   ```bash
   cd /Users/minhkhoi/Documents/Project/habitTracker
   ```
2. Open the Xcode project:
   ```bash
   open HabitTracker.xcodeproj
   ```

---

## 2. Running on Your Physical iPhone (Free Personal Apple ID)

Apple allows anyone with a standard, free Apple ID to deploy and test apps directly on their personal physical devices using a **Personal Team** provisioning profile.

### Step 1: Add Your Free Apple ID to Xcode
1. In Xcode's top menu bar, go to **Xcode > Settings...** (or press `Cmd + ,`).
2. Select the **Accounts** tab.
3. Click the **`+`** button in the lower-left corner and choose **Apple ID**.
4. Sign in with your regular Apple ID and password.

### Step 2: Configure Signing in the Project
1. In the Xcode Project Navigator (left sidebar), click the top-level **HabitTracker** project icon.
2. Select the **HabitTracker** target under *Targets*.
3. Go to the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. In the **Team** dropdown, select your name: **"[Your Name] (Personal Team)"**.
6. In **Bundle Identifier**, change `com.habittracker.app` to something unique (e.g., `com.<yourname>.HabitTracker`).

### Step 3: Enable Developer Mode on Your iPhone (iOS 16, 17, 18+)
If you haven't run your own apps on this iPhone before:
1. On your iPhone, open **Settings > Privacy & Security**.
2. Scroll to the very bottom and tap **Developer Mode**.
3. Toggle it **ON** and restart your iPhone when prompted.
4. After restarting, unlock your phone and tap **Turn On** to confirm.

### Step 4: Plug in and Run
1. Connect your iPhone to your Mac using a USB cable (or Wi-Fi if enabled).
2. If prompted on your iPhone, tap **Trust This Computer** and enter your passcode.
3. In Xcode's top toolbar, click the device selector next to the Run button and select your physical iPhone.
4. Press **Run** (or `Cmd + R`).

### Step 5: Trust the Developer Certificate (First time only)
When the app installs, iOS will display an "Untrusted Developer" alert:
1. On your iPhone, go to **Settings > General > VPN & Device Management**.
2. Under **Developer App**, tap your Apple ID email.
3. Tap **Trust "[Your Apple ID]"** and confirm.
4. Open **Habit Tracker** from your iPhone home screen!

---

## 3. Running in the iOS Simulator

1. In Xcode's top toolbar device selector, choose any simulator (e.g., **iPhone 16 Pro** or **iPhone 16**).
2. Press **Run** (`Cmd + R`).
3. The app will launch in the simulator.

> [!NOTE]
> The iOS Simulator does not have a real camera sensor. HabitTracker automatically detects when the camera hardware is unavailable and opens the **Photo Library picker** instead, so you can test smoothly without crashes.

---

## 4. App Architecture & Key Features

- **Black & White Minimalist Theme**: Distraction-free monochrome UI with high contrast, crisp typography, and clean hairline cards.
- **Preloaded Technical Habits**:
  - Data Structures & Algorithms (DSA)
  - Swift & iOS Development
  - System Design
  - Data Engineering (DE)
  - Python for DE & Tools
  - Coding & Side Projects
- **Background-Safe Focus Timer**: Uses target completion timestamps so locking your screen or switching apps won't pause or desync the countdown.
- **Proof of Work Checklist**: Snap a photo proof of your terminal, code, or solved problems upon timer timeout or task completion.
- **Local SwiftData Persistence**: All habits, timed sessions, notes, and proof photos are stored safely on device in the sandboxed documents directory.
