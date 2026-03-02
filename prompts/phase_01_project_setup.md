# Phase 01 — Project Setup & Architecture
**Estimated Time: 1–2 days**

## Prompt for Google Antigravity / AI IDE

```
Create a complete Flutter project scaffold for GitaLife, a spiritual mobile app for ISKCON students.

Project setup:
- App name: GitaLife
- Package: com.gitalife
- Flutter 3.16+ with Dart 3.2+
- Minimum SDK: Android 21 (5.0), iOS 13

Architecture:
- State management: Riverpod (flutter_riverpod: ^2.4.0)
- Navigation: GoRouter (go_router: ^13.0.0)
- Backend: Firebase (Auth, Firestore, Storage, Messaging)
- Local DB: SQLite (sqflite) for Gita verses, Hive for Japa logs
- Audio: just_audio + audio_service for background playback

Create the complete folder structure with stub implementations:
- lib/main.dart — Firebase init, Hive init, ProviderScope
- lib/app/router.dart — GoRouter with all routes (auth, home, gita, japa, audio, lectures, profile, admin)
- lib/app/theme.dart — Material 3 theme with saffron (#FF6600), gold (#D4A017), cream (#FFF8F0), navy (#1A1A2E)
- lib/models/ — UserModel, AttendanceSession, AttendanceRecord, LectureModel, AudioTrackModel, VerseModel, JapaLog
- lib/services/ — AuthService, AttendanceService, AudioService, GitaService, JapaService, LectureService, NotificationService
- lib/providers/ — Riverpod providers for each service
- lib/screens/ — All screens as ConsumerWidget stubs
- lib/widgets/ — Reusable widget stubs

Use Poppins font via google_fonts for the entire app.
```

## Success Criteria
- [ ] `flutter pub get` runs without errors
- [ ] `flutter analyze` shows no errors
- [ ] App launches and shows Login screen
- [ ] All routes are navigable without crashes
- [ ] Theme colors match specification

## Dependencies
- None (this is Phase 1)
