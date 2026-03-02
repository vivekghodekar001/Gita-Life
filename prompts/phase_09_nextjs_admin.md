# Phase 09 — Next.js Admin Web Dashboard
**Estimated Time: 3–4 days**

## Prompt for Google Antigravity / AI IDE

```
Create a Next.js 14 admin web dashboard for GitaLife using the App Router, shadcn/ui, and Firebase.

Tech stack:
- Next.js 14 (App Router)
- TypeScript
- shadcn/ui components
- Tailwind CSS
- Firebase (same project as Flutter app)
- Recharts for charts

Project structure:
admin-dashboard/
├── app/
│   ├── layout.tsx — Root layout with sidebar nav
│   ├── page.tsx — Dashboard home with stats
│   ├── students/
│   │   ├── page.tsx — Student list with filters
│   │   └── [uid]/page.tsx — Student detail
│   ├── attendance/
│   │   ├── page.tsx — Sessions list
│   │   └── [sessionId]/page.tsx — Session detail with mark attendance
│   ├── lectures/
│   │   └── page.tsx — Manage lectures CRUD
│   ├── audio/
│   │   └── page.tsx — Manage audio tracks CRUD
│   ├── notifications/
│   │   └── page.tsx — Send notifications, history
│   └── settings/
│       └── page.tsx — Admin settings
├── components/
│   ├── Sidebar.tsx
│   ├── StatsCard.tsx
│   ├── DataTable.tsx
│   ├── AttendanceChart.tsx
│   └── StudentCard.tsx
└── lib/
    └── firebase.ts — Firebase client initialization

Dashboard features:
- Stats: total students, active today, sessions this week, avg attendance %
- Student management: approve/suspend, view profiles, attendance history
- Attendance: create sessions, view/export reports, charts
- Lectures: CRUD with YouTube URL validation
- Audio: CRUD with Google Drive/Firebase Storage upload
- Notifications: send to all or specific students, history

Authentication: Firebase Auth (admin only, redirect to login if not admin role)
```

## Success Criteria
- [ ] Admin dashboard shows real-time data from Firestore
- [ ] Student approval/suspension works
- [ ] Attendance reports can be exported as CSV
- [ ] Lectures and audio can be managed (CRUD)
- [ ] Notifications can be sent via admin panel
- [ ] Charts show attendance trends

## Dependencies
- Phases 01-08 (Firestore data structure must be established)
- Firebase project with Firestore data
