# Phase 04 — Bhagavad Gita Reader
**Estimated Time: 2–3 days**

## Prompt for Google Antigravity / AI IDE

```
Implement the complete Bhagavad Gita reader for GitaLife using a SQLite database.

Database setup:
- Run scripts/build_gita_db.dart to fetch all 700 verses from bhagavadgitaapi.in
- Copy gita.db from assets/db/ to app documents directory on first launch
- Table schema: id, chapter_number, verse_number, text_devanagari, text_transliteration, text_english, purport, is_bookmarked

GitaService methods:
- initGitaDb(): Open database, copy from assets on first launch
- getChapters(): Return 18 chapters with names and verse counts
- getVersesByChapter(chapterNumber): Return all verses for chapter
- getVerse(chapter, verse): Return single verse
- searchVerses(query): FTS search across all text fields
- toggleBookmark(verseId): Toggle bookmark status
- getBookmarkedVerses(): Return all bookmarked verses

ChapterListScreen (/gita):
- Grid or list of 18 chapters
- Each chapter card shows: chapter number, name in Sanskrit & English, verse count
- Beautiful saffron/gold gradient cards

VerseListScreen (/gita/chapter/:chapterId):
- List of verses with devanagari preview
- Swipe to bookmark
- Sticky header with chapter name

VerseDetailScreen (/gita/chapter/:chapterId/verse/:verseId):
- Full devanagari text (NotoSerifDevanagari font)
- Transliteration text
- English translation
- Purport (expandable)
- Bookmark button
- Share button
- Font size controls
- Navigate to previous/next verse

GitaSearchScreen (/gita/search):
- Search bar with real-time search
- Results show verse number and snippet
- Highlight search term in results

BookmarksScreen (/gita/bookmarks):
- List of all bookmarked verses
- Remove bookmark by swiping
```

## Success Criteria
- [ ] All 700 verses are accessible
- [ ] Devanagari text renders correctly with NotoSerifDevanagari font
- [ ] Search works across all text fields
- [ ] Bookmarks persist across app restarts
- [ ] Chapter and verse navigation works smoothly

## Dependencies
- Phase 01 (project setup)
- Phase 02 (authentication)
- Run build_gita_db.dart script first
