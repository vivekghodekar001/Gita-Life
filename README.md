<div align="center">
  <img width="1200" height="475" alt="GitaLife Banner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# GitaLife — Spiritual Companion App for ISKCON Students

A Flutter mobile app for ISKCON students featuring a Bhagavad Gita reader, Japa counter, audio streaming, video lectures, attendance tracking, and push notifications — with an admin dashboard.

---

## Screenshots

> _Screenshots will be added after initial implementation phases_

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Framework | Flutter 3.16+ (Dart 3.2+) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter 13.x |
| Backend | Firebase (Auth, Firestore, Storage, Messaging) |
| Local Database | SQLite (Gita verses), Hive (Japa logs, settings) |
| Audio | just_audio + audio_service |
| Video | youtube_player_flutter |
| UI Components | Material 3, google_fonts (Poppins), shimmer, fl_chart |
| Web Admin | Next.js 14 + shadcn/ui (Phase 09) |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.16+ ([install](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.2+
- Firebase CLI ([install](https://firebase.google.com/docs/cli))
- Android Studio or VS Code with Flutter extension

### 1. Clone and Install

```bash
git clone https://github.com/vivekghodekar001/Gita-Life
cd Gita-Life
flutter pub get
```

### 2. Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable these services:
   - Authentication (Email/Password + Phone)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Cloud Messaging
3. Add Android app with package name `com.gitalife`
4. Download `google-services.json` → place in `android/app/`
5. Add iOS app with bundle ID `com.gitalife`
6. Download `GoogleService-Info.plist` → place in `ios/Runner/`
7. Deploy Firestore rules: `firebase deploy --only firestore:rules`

### 3. Build the Gita Database

```bash
# Fetch all 700 verses and create SQLite database
dart run scripts/build_gita_db.dart
```

### 4. Run the App

```bash
flutter run
```

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app/
│   ├── router.dart        # GoRouter navigation
│   └── theme.dart         # Material 3 theme
├── models/                # Data models
├── services/              # Firebase & local data services
├── providers/             # Riverpod state providers
├── screens/               # UI screens
│   ├── auth/
│   ├── home/
│   ├── gita/
│   ├── japa/
│   ├── audio/
│   ├── lectures/
│   ├── attendance/
│   ├── profile/
│   └── admin/
└── widgets/               # Reusable UI components
```

---

## Using the Antigravity Prompts

The `prompts/` directory contains 10 structured prompts for AI-driven development with Google Antigravity:

| Phase | File | Feature |
|---|---|---|
| 01 | `phase_01_project_setup.md` | Flutter scaffold, theme, router |
| 02 | `phase_02_authentication.md` | Firebase Auth, login, register, OTP |
| 03 | `phase_03_home_attendance.md` | Home dashboard, attendance tracking |
| 04 | `phase_04_gita_reader.md` | SQLite Gita reader, search, bookmarks |
| 05 | `phase_05_japa_counter.md` | Hive-based Japa counter with charts |
| 06 | `phase_06_audio_player.md` | Audio streaming, mini player, downloads |
| 07 | `phase_07_lectures_notifications.md` | YouTube lectures, FCM notifications |
| 08 | `phase_08_admin_profile.md` | Admin dashboard, profile, settings |
| 09 | `phase_09_nextjs_admin.md` | Next.js web admin dashboard |
| 10 | `phase_10_polish_deploy.md` | Offline handling, polish, deployment |

To use a prompt:
1. Open the corresponding `.md` file in `prompts/`
2. Copy the prompt text from the code block
3. Paste into Google Antigravity (or your AI IDE)
4. Follow the success criteria to verify completion

---

## Theme Colors

| Name | Hex | Usage |
|---|---|---|
| Saffron | `#FF6600` | Primary color, AppBar, buttons |
| Gold | `#D4A017` | Secondary, accents |
| Cream | `#FFF8F0` | Background |
| Navy | `#1A1A2E` | Text, dark elements |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
