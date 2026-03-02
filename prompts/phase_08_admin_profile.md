# Phase 08 — Admin Dashboard & Profile
**Estimated Time: 2 days**

## Prompt for Google Antigravity / AI IDE

```
Implement Admin Dashboard, Student Management, and User Profile screens for GitaLife.

ADMIN DASHBOARD (/admin):
- Stats cards: Total students, Active today, Pending approvals, Sessions this week
- Quick action buttons: Mark Attendance, Add Lecture, Upload Audio, Send Notification
- Recent activity feed
- Only accessible to users with role == 'admin' (use RoleGuard)

ManageStudentsScreen (/admin/students):
- List all users from /users collection
- Filter by status (pending/active/suspended)
- Approve pending students (status: pending → active)
- Suspend students (status: active → suspended)
- View student profile details
- Export student list as CSV

ManageLecturesScreen (/admin/lectures):
- List all lectures (including inactive)
- Add new lecture form: title, description, YouTube URL, topic
- Edit/delete existing lectures
- Toggle active/inactive

ManageAudioScreen (/admin/audio):
- List all audio tracks
- Add new track: title, artist, category, source type, URL or upload
- Edit/delete tracks
- Toggle active/inactive

PROFILE:

ProfileScreen (/profile):
- Profile photo (image_picker for upload to Firebase Storage)
- Edit: fullName, phoneNumber
- Read-only: rollNumber, email, enrollmentDate, role, status
- Attendance percentage summary
- Japa statistics summary
- Logout button

SettingsScreen (/settings):
- Notification settings (toggle types)
- Japa preferences (target malas, vibration, sound)
- Theme toggle (light/dark)
- Font size for Gita reader
- Clear cache button
- App version info
- Rate app link
```

## Success Criteria
- [ ] Admin can approve/suspend students
- [ ] Admin can manage lectures and audio
- [ ] User can update profile photo and name
- [ ] Settings persist across app restarts
- [ ] Non-admin users cannot access admin routes

## Dependencies
- Phases 01-07
