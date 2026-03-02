# Phase 05 — Japa Counter
**Estimated Time: 1–2 days**

## Prompt for Google Antigravity / AI IDE

```
Implement the Japa (chanting) counter for GitaLife using Hive for local storage.

JapaLog Hive model (typeId: 0):
- date: String (YYYY-MM-DD)
- totalMalas: int (108 beads = 1 mala)
- totalBeads: int
- targetMalas: int (daily target)
- goalReached: bool
- lastUpdated: String (ISO timestamp)

JapaService methods:
- getTodayLog(): Get or create today's JapaLog
- recordBead(date): Increment bead count, auto-complete mala at 108
- completeMala(date): Increment mala, reset beads, check goal
- setDailyTarget(target): Save to settings box, update today's log
- getWeekHistory(): Last 7 days of logs
- getMonthHistory(): Last 30 days of logs
- syncToFirestore(userId): Sync all logs to /japa_logs/{userId}/

JapaCounterScreen (/japa):
- Large circular progress indicator showing beads in current mala (0-108)
- Big tap button in center (vibrates on each tap)
- Mala count display (e.g., "3 / 16 malas")
- Bead count in current mala
- Daily target selector
- Progress percentage
- History button → /japa/history

JapaHistoryScreen (/japa/history):
- Bar chart of last 7 days (fl_chart)
- Calendar heatmap for month view
- Statistics: average malas/day, best day, current streak

Settings for Japa:
- Daily target (number of malas)
- Vibration on/off
- Sound on/off (click sound on each bead)
- Auto-sync to cloud
```

## Success Criteria
- [ ] Tapping increments bead count with haptic feedback
- [ ] Mala auto-completes at 108 beads
- [ ] Progress persists if app is closed
- [ ] Charts show accurate history data
- [ ] Goal reached notification shows when target is hit

## Dependencies
- Phase 01 (project setup, Hive setup)
- Phase 02 (authentication, for cloud sync)
