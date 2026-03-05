import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gita_service.dart';
import '../services/gita_api_service.dart';
import '../models/verse_model.dart';

final gitaServiceProvider = Provider<GitaService>((ref) => GitaService());

final chaptersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(gitaServiceProvider).getChapters();
});

final versesByChapterProvider = FutureProvider.family<List<VerseModel>, int>((ref, chapterNumber) {
  return ref.watch(gitaServiceProvider).getVersesByChapter(chapterNumber);
});

final gitaSearchProvider = FutureProvider.family<List<VerseModel>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(gitaServiceProvider).searchVerses(query);
});

final bookmarkedVersesProvider = FutureProvider<List<VerseModel>>((ref) {
  return ref.watch(gitaServiceProvider).getBookmarkedVerses();
});

// ------------------------------------------------------------------
// NEW: VEDICSCRIPTURES.GITHUB.IO API INTEGRATION
// ------------------------------------------------------------------

// 1. Language Toggle State Management (en or hi)
class GitaLanguageNotifier extends StateNotifier<String> {
  GitaLanguageNotifier() : super('en') {
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('gita_lang') ?? 'en';
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gita_lang', lang);
  }
  
  void toggle() {
    setLanguage(state == 'en' ? 'hi' : 'en');
  }
}

final gitaLanguageProvider = StateNotifierProvider<GitaLanguageNotifier, String>((ref) {
  return GitaLanguageNotifier();
});

// 2. Data Providers using GitaApiService
final gitaApiChaptersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(gitaApiServiceProvider);
  return await api.getChapters();
});

final gitaApiVerseProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, chapterVerseKey) async {
  // key format: "chapterNumber_verseNumber" e.g. "1_1"
  final parts = chapterVerseKey.split('_');
  final chapter = int.parse(parts[0]);
  final verse = int.parse(parts[1]);
  
  final api = ref.watch(gitaApiServiceProvider);
  return await api.getVerse(chapter, verse);
});

