import 'package:sqflite/sqflite.dart';
import '../models/verse_model.dart';

class GitaService {
  Database? _db;

  Future<void> initGitaDb() async {
    // TODO: Open/copy SQLite database from assets/db/gita.db to app documents directory
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> getChapters() async {
    // TODO: Query distinct chapters with verse counts from database
    throw UnimplementedError();
  }

  Future<List<VerseModel>> getVersesByChapter(int chapterNumber) async {
    // TODO: Query all verses for a given chapter number
    throw UnimplementedError();
  }

  Future<VerseModel?> getVerse(int chapterNumber, int verseNumber) async {
    // TODO: Query a single verse by chapter and verse number
    throw UnimplementedError();
  }

  Future<List<VerseModel>> searchVerses(String query) async {
    // TODO: Full-text search across devanagari, transliteration, and english fields
    throw UnimplementedError();
  }

  Future<void> toggleBookmark(int verseId) async {
    // TODO: Toggle is_bookmarked field for a verse in the database
    throw UnimplementedError();
  }

  Future<List<VerseModel>> getBookmarkedVerses() async {
    // TODO: Query all verses where is_bookmarked = 1
    throw UnimplementedError();
  }
}
