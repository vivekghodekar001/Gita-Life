<div align="center">
  <img src="assets/app_logo.png" alt="GitaLife logo" width="112">
  <h1>GitaLife</h1>
  <p><strong>Read. Chant. Learn. Stay connected.</strong></p>
  <p>A Flutter companion for Bhagavad Gita study and ISKCON student communities.</p>
  <p>
    <a href="#quick-start">Quick start</a> ·
    <a href="#firebase-setup">Firebase setup</a> ·
    <a href="#validation">Validation</a> ·
    <a href="#contributing">Contributing</a>
  </p>
</div>

---

GitaLife brings scripture reading, a daily Japa practice, audio, lectures, assignments, and attendance into one application. Students, counselors, and administrators have separate responsibilities, enforced by Firebase rules as well as the interface.

## What is included

| Area | Current implementation |
| --- | --- |
| Bhagavad Gita | Chapter and verse browsing, translations, language preferences, and bookmarks. Content comes from the Vedic Scriptures HTTP API and is cached in memory during a session. |
| Japa | Bead and mala counting, daily targets, history, and local Hive storage with Firestore sync methods. |
| Audio | Categorized library, streaming, playback controls, and device-file downloads on supported native platforms. |
| Lectures | Lecture lists and embedded video playback. |
| Community | Student approval, counselor assignments, preaching attendance, and legacy class attendance management. |
| Assignments | Assignment management and student submission workflows. |
| Administration | An integrated Flutter admin panel for accounts, media, attendance, and announcements. |
| Notifications | FCM/local-notification integration and a Firestore announcement queue. A trusted server-side sender is needed to deliver queued broadcasts. |

**Implementation boundaries:** Gita search is a placeholder. The Gita reader does not ship an offline SQLite database. The `admin-dashboard/` folder contains partial Next.js source files, not a runnable standalone application; use the Flutter admin panel. Web builds are supported, but native file downloads and mobile notification behavior require platform-specific testing. Firebase configuration currently covers Android and web; other platform scaffolds need additional setup.

## Technology

- **Application:** Flutter, Dart, Material, custom sacred theme, and bundled Devanagari fonts.
- **State and navigation:** Riverpod 2 and GoRouter 13.
- **Backend:** Firebase Authentication, Cloud Firestore, Cloud Storage, and Cloud Messaging.
- **Local data:** Hive and SharedPreferences.
- **Media:** just_audio, audio_service, YouTube iframe player, video_player, and Chewie.
- **Validation:** Flutter tests and Firebase emulator security-rule tests.

## Quick start

Use **Flutter 3.41.2** for the pinned build configuration. The declared minimum is Flutter 3.38.4 / Dart 3.10.3; the old Flutter 3.16 setup instructions do not satisfy the current dependency lockfile.

Install Flutter and verify the platform toolchain:

```bash
flutter doctor
```

Clone and resolve dependencies:

```bash
git clone https://github.com/vivekghodekar001/Gita-Life.git
cd Gita-Life
flutter pub get
```

Complete Firebase setup below, then run:

```bash
# Browser
flutter run -d chrome

# Connected Android device or emulator
flutter devices
flutter run -d DEVICE_ID
```

Replace `DEVICE_ID` with an ID shown by `flutter devices`. Android requires Android Studio/SDK tools and Java 17 or newer. Check the generated platform tooling requirements with `flutter doctor`.

## Firebase setup

The checked-in client options reference an existing Firebase project. To use your own backend, regenerate the options instead of copying another project's identifiers.

1. Create or select a Firebase project and enable **Authentication**, **Cloud Firestore**, and **Cloud Storage**. Enable Email/Password and Google sign-in if you want both login methods.
2. Install the Firebase and FlutterFire tools:

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project YOUR_PROJECT_ID --platforms android,web
   ```

3. The Android application ID is **`com.gitalife`**. Place its downloaded `google-services.json` in `android/app/` when needed by the Android Google Services plugin. For Google sign-in on Android, register your signing certificate fingerprints in Firebase. For web, add your localhost/deployment domains to Authentication's authorized domains.
4. Check `lib/firebase_options.dart` and `firebase.json`, including the Storage bucket, against the selected project. Add `.firebaserc` locally or pass `--project` explicitly.
5. Deploy the rules and indexes only to your intended project:

   ```bash
   firebase deploy --project YOUR_PROJECT_ID --only firestore:rules,firestore:indexes,storage
   ```

Client configuration identifies a Firebase project; authorization comes from the deployed rules. Keep service-account keys, private credentials, `.env` files, and local signing configuration out of Git.

### First administrator and account approval

New accounts must be created as **`role: student`**, **`status: pending`**, with `uid` equal to their Authentication UID. Students cannot promote or approve themselves.

To bootstrap the first administrator, register normally, then use a trusted Firebase Console account or Admin SDK to set that user's `/users/{uid}` document to:

```json
{
  "role": "admin",
  "status": "active"
}
```

Update these fields on the existing profile; preserve the other fields. The administrator can then approve users and assign counselors from the Flutter admin panel. Counselors can read their assigned users and mark their attendance; shared audio and lecture uploads require an active administrator. Profile-photo writes are limited to the owner's `profile_photos/{uid}.jpg` path.

## Validation

Run application checks from the repository root:

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

The analyzer command still fails on errors while reporting existing warning/info diagnostics. Formatting cleanup can be done separately from functional changes.

Security rules have their own local test suite. Install **Node.js 22 or 24** and **Java 21**, then run:

```bash
npm ci
npm run test:rules
```

These tests use `firebase.test.json` and the **`demo-gita-life-tests`** project, with Firestore at `127.0.0.1:8085` and Storage at `127.0.0.1:9195`. They test privilege escalation, self-approval, counselor scope, locked attendance, and file ownership without deploying rules or accessing production data. The first run downloads the emulators.

## Web deployment

Vercel serves the **Flutter web application**. Import the repository with its root directory unchanged; the checked-in configuration uses:

| Setting | Value |
| --- | --- |
| Framework | Other |
| Install command | `bash scripts/vercel-install.sh` |
| Build command | `bash vercel-build.sh` |
| Output | `build/web` |

The build script installs Flutter 3.41.2 into the ignored `.flutter-sdk/` directory and reuses it during the build. It does not install the incomplete Next.js dashboard. Add the deployed domain to Firebase Authentication before testing sign-in. Deployment requires network access for SDKs, packages, fonts, and app content; it is not an offline installation.

For Android release distribution, configure your own signing key. The current Gradle release configuration uses a debug signing key and must be changed before publishing to an app store.

## Repository map

```text
lib/
  app/          Themes and navigation
  models/       User, media, attendance, assignment, and Japa models
  providers/    Riverpod state and application actions
  services/     Firebase, local data, media, and Gita API access
  screens/      Student, counselor, and administrator workflows
  widgets/      Shared visual components
assets/         Images, fonts, and local audio placeholder
android/        Android application configuration
web/            Flutter web host and icons
test/           Flutter and Firebase security regression tests
admin-dashboard/ Partial standalone dashboard source
firestore.rules Firestore authorization rules
storage.rules   File ownership and administrator upload rules
```

## Contributing

Collaborators can push a feature branch to this repository; external contributors can use a fork.

```bash
git switch -c fix/describe-your-change
# Make and validate the change
git add PATHS_YOU_CHANGED
git commit -m "Describe the change"
git push -u origin fix/describe-your-change
```

Open a pull request against `main` with the problem, the resulting behavior, and the checks you ran. Include screenshots for visible changes. Changes to Firebase rules should include emulator regression tests, and rule deployment should be performed separately against the intended Firebase project.

## License

A license file is not currently included. The repository owner should add one before describing this project as MIT-licensed or granting reuse rights.
