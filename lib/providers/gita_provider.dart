import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gita_service.dart';
import '../models/gita_verse.dart';

// ── Chapters Provider ──
final chaptersProvider = FutureProvider<List<GitaChapter>>((ref) async {
  return GitaService.getAllChapters();
});

// ── Selected Chapter ──
final selectedChapterProvider = StateProvider<int>((ref) => 1);

// ── Selected Verse ──
final selectedVerseProvider = StateProvider<int>((ref) => 1);

// ── Current Verse Provider (watches selected chapter + verse) ──
final currentVerseProvider = FutureProvider<GitaVerse>((ref) async {
  final chapter = ref.watch(selectedChapterProvider);
  final verse = ref.watch(selectedVerseProvider);
  return GitaService.getVerse(chapter, verse);
});

// ── Translator Provider ──
// Options: 'sivananda', 'purohit', 'hindi'
final translatorProvider = StateProvider<String>((ref) => 'sivananda');

// ── Language Toggle (for chapter list EN/Hindi display) ──
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
