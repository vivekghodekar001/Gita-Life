# Phase 06 — Audio Player
**Estimated Time: 2–3 days**

## Prompt for Google Antigravity / AI IDE

```
Implement the Audio Player for GitaLife supporting streaming from Google Drive and Firebase Storage, with background playback using audio_service.

AudioTrackModel fields: trackId, title, artist, category (bhajan/kirtan/lecture_audio/other), sourceType (google_drive/firebase_storage), driveFileId, storageRef, streamUrl, durationSeconds, fileSizeBytes, coverImageUrl, isActive, playCount, addedBy, createdAt

AudioService methods:
- getAudioTracks(category?): Fetch from Firestore /audio_tracks, filtered by category
- buildStreamUrl(track): For google_drive: use direct link format, for firebase_storage: getDownloadURL
- downloadTrack(track): Download to local storage, save path in Hive 'downloads' box
- getDownloadedTracks(): Return tracks from Hive with local file paths
- deleteDownload(trackId): Delete local file and Hive entry
- incrementPlayCount(trackId): ++ playCount in Firestore

AudioLibraryScreen (/audio):
- Tab bar: All, Bhajans, Kirtans, Lectures
- List/grid of audio tracks with cover image, title, artist, duration
- Download button on each track
- Mini player at bottom when audio is playing

AudioPlayerScreen (/audio/player/:trackId):
- Full-screen player with cover art
- Track info (title, artist, category)
- Progress slider
- Play/pause, previous/next buttons
- Volume slider
- Speed control (0.75x, 1x, 1.25x, 1.5x, 2x)
- Loop and shuffle toggles
- Download button
- Share button

DownloadsScreen (/audio/downloads):
- List of downloaded tracks
- File size and local path
- Delete button

AudioMiniPlayer widget:
- Persistent mini player at bottom of screen
- Show when audio is playing
- Album art, title, play/pause button
- Tap to open full player

Background playback setup:
- Use audio_service AudioHandler
- Show notification with controls
- Handle headphone disconnect
- Lock screen controls
```

## Success Criteria
- [ ] Audio streams from Google Drive URLs
- [ ] Audio streams from Firebase Storage
- [ ] Background playback works with notification controls
- [ ] Downloads work and play offline
- [ ] Mini player persists across screen navigation

## Dependencies
- Phase 01 (project setup)
- Phase 02 (authentication)
