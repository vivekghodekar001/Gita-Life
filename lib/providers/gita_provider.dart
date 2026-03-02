import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gita_service.dart';
import '../models/verse_model.dart';

final gitaServiceProvider = Provider<GitaService>((ref) => GitaService());

final chaptersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(gitaServiceProvider).getChapters();
});

final versesByChapterProvider = FutureProvider.family<List<VerseModel>, int>((ref, chapterNumber) {
  return ref.watch(gitaServiceProvider).getVersesByChapter(chapterNumber);
});

final bookmarkedVersesProvider = FutureProvider<List<VerseModel>>((ref) {
  return ref.watch(gitaServiceProvider).getBookmarkedVerses();
});
