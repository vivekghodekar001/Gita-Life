# Phase 07 — Lectures & Push Notifications
**Estimated Time: 2 days**

## Prompt for Google Antigravity / AI IDE

```
Implement YouTube Lecture player and FCM Push Notifications for GitaLife.

LECTURES:

LectureModel fields: lectureId, title, description, youtubeVideoId, thumbnailUrl, topic, durationMinutes, viewCount, isActive, addedBy, createdAt

LectureService methods:
- getLectures(topic?): Fetch active lectures from Firestore, ordered by createdAt desc
- getLectureById(lectureId): Get single lecture
- addLecture(lecture): Admin adds new lecture (validates YouTube video ID)
- updateLecture(id, data): Admin updates lecture metadata
- deleteLecture(id): Soft delete (isActive = false)
- incrementViewCount(id): Atomic increment on view

LectureListScreen (/lectures):
- Search bar to filter by title or topic
- Filter chips for topics
- List with YouTube thumbnail, title, topic, duration, view count
- Tap to open player

LecturePlayerScreen (/lectures/player/:lectureId):
- YouTube player (youtube_player_flutter)
- Video title and description
- Related lectures section below
- Share button

NOTIFICATIONS:

NotificationService methods:
- initNotifications(): Setup FCM + local notifications, register handlers
- requestPermission(): Ask user for notification permission
- sendToAll(title, body): Send via Cloud Function or FCM HTTP API
- getNotificationHistory(): Fetch /notifications collection
- onMessageReceived(message): Show local notification when app is in foreground

FCM Setup:
- Save FCM token to user document on login
- Handle background messages with firebase_messaging
- Handle notification tap to navigate to relevant screen
- Show local notification for foreground messages

SendNotificationScreen (/admin/notifications) [Admin only]:
- Title and body input fields
- Send to all students button
- Notification history list below
```

## Success Criteria
- [ ] YouTube videos play correctly in player
- [ ] Lectures are filterable by topic
- [ ] Push notifications received in background and foreground
- [ ] Notification taps navigate to correct screen
- [ ] Admin can send notifications to all users

## Dependencies
- Phase 01 (project setup)
- Phase 02 (authentication)
- Firebase Cloud Messaging configured in Firebase console
