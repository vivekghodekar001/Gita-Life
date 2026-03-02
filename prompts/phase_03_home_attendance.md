# Phase 03 — Home Dashboard & Attendance
**Estimated Time: 2–3 days**

## Prompt for Google Antigravity / AI IDE

```
Implement the Home Dashboard and Attendance tracking system for GitaLife.

Home Dashboard (/home):
- Welcome card with user name and spiritual quote of the day
- Grid of 6 feature cards: Gita Reader, Japa Counter, Audio, Lectures, Attendance, Profile
- Today's japa progress summary card
- Upcoming attendance sessions card
- Offline indicator banner at top when no connection

Attendance System:
AttendanceService methods:
- createSession(data): Admin creates attendance session with title, topic, date
- markAttendance(sessionId, studentUid, status): Mark present/absent/late
- submitSession(sessionId): Lock session, update counts
- getStudentAttendance(studentUid): Return list of attendance records
- getAttendancePercentage(studentUid): Calculate percentage
- exportSessionCsv(sessionId): Generate CSV string for export
- getSessionList(): List all sessions ordered by date

AttendanceHistoryScreen (/attendance/history):
- List of all sessions student attended
- Attendance percentage indicator (color: green >75%, yellow 50-75%, red <50%)
- Filter by month
- Each item shows: date, topic, status chip (present/absent/late)

MarkAttendanceScreen (/admin/attendance/mark/:sessionId) [Admin only]:
- List of all students with roll number and name
- Toggle buttons for present/absent/late for each student
- Search/filter students by name or roll number
- Submit button to lock session
- Export CSV button after session is locked

Firestore structure:
- /attendance_sessions/{sessionId}
- /attendance_records/{recordId}
```

## Success Criteria
- [ ] Home dashboard shows all feature cards
- [ ] Admin can create and manage attendance sessions
- [ ] Students can view their attendance history
- [ ] Attendance percentage is calculated correctly
- [ ] CSV export works and can be shared
- [ ] Sessions are locked after submission

## Dependencies
- Phase 01 (project setup)
- Phase 02 (authentication)
