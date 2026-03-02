# Phase 10 — Polish & Deploy
**Estimated Time: 2–3 days**

## Prompt for Google Antigravity / AI IDE

```
Polish the GitaLife Flutter app and prepare for production deployment.

OFFLINE HANDLING:
- Implement connectivity_plus to detect network status
- Show OfflineBanner widget at top of all screens when offline
- Cache Firestore data for offline access using Firestore offline persistence
- Cache audio tracks with local file system
- Cache Gita database is already local (SQLite)

LOADING STATES:
- Replace all placeholder screens with proper shimmer loading using ShimmerLoading widget
- Add pull-to-refresh on all list screens
- Add pagination for long lists (lectures, audio, students)

ERROR HANDLING:
- Global error handler for uncaught exceptions
- Specific error messages for common Firebase errors
- Retry buttons on failed network requests

ONBOARDING:
- Splash screen with GitaLife logo and saffron/gold gradient
- 3-screen onboarding carousel (shown once on first launch):
  1. "Study the Gita Daily" — Gita reader feature
  2. "Track Your Japa" — Japa counter feature
  3. "Never Miss a Lecture" — Audio and video features
- Skip and Get Started buttons

PERFORMANCE:
- Image caching with cached_network_image (already in deps)
- Lazy loading for long lists
- Minimize rebuilds with const constructors

APP STORE PREPARATION:
- App icon (saffron background with lotus/om symbol)
- Splash screen
- Android: update AndroidManifest.xml permissions
- iOS: update Info.plist permissions
- Generate release keystore
- Build release APK: flutter build apk --release
- Build App Bundle: flutter build appbundle --release

FINAL CHECKLIST:
- All TODO comments replaced with real implementation
- No debug/test code in production
- flutter analyze passes with no errors
- flutter test passes
- App works on Android 5.0+ and iOS 13+
```

## Success Criteria
- [ ] App works fully offline for cached content
- [ ] Shimmer loading shows on all data screens
- [ ] Onboarding shown on first launch only
- [ ] Release APK builds without errors
- [ ] App icon and splash screen look professional
- [ ] flutter analyze shows zero errors

## Dependencies
- All previous phases complete
