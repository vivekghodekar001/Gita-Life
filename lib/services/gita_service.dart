import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/verse_model.dart';

class GitaService {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    await initGitaDb();
    return _db!;
  }

  Future<void> initGitaDb() async {
    if (kIsWeb) {
      throw Exception("Offline SQLite database is not supported on Web. Please run on Android, iOS, or Windows to test the Gita Reader.");
    }
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docDir.path, 'gita.db');
    
    // Copy if it doesn't exist
    if (!await File(dbPath).exists()) {
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/db/gita.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print("Error copying database: $e");
      }
    }
    
    _db = await openDatabase(dbPath);
  }

  Future<List<Map<String, dynamic>>> getChapters() async {
    final d = await db;
    // We group by chapter to get verse counts. 
    // Usually they are 1 to 18 sequentially.
    final result = await d.rawQuery('''
      SELECT chapter_number, COUNT(*) as verse_count
      FROM verses 
      GROUP BY chapter_number
      ORDER BY chapter_number ASC
    ''');
    return result;
  }

  Future<List<VerseModel>> getVersesByChapter(int chapterNumber) async {
    final d = await db;
    final result = await d.query(
      'verses',
      where: 'chapter_number = ?',
      whereArgs: [chapterNumber],
      orderBy: 'verse_number ASC',
    );
    return result.map((m) => VerseModel.fromMap(m)).toList();
  }

  Future<VerseModel?> getVerse(int chapterNumber, int verseNumber) async {
    final d = await db;
    final result = await d.query(
      'verses',
      where: 'chapter_number = ? AND verse_number = ?',
      whereArgs: [chapterNumber, verseNumber],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return VerseModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<VerseModel>> searchVerses(String query) async {
    final d = await db;
    final result = await d.rawQuery('''
      SELECT verses.* 
      FROM verses_fts 
      JOIN verses ON verses.id = verses_fts.rowid
      WHERE verses_fts MATCH ?
      ORDER BY rank
      LIMIT 50
    ''', [query]);
    
    return result.map((m) => VerseModel.fromMap(m)).toList();
  }

  Future<void> toggleBookmark(int verseId) async {
    final d = await db;
    // get current status
    final current = await d.query('verses', columns: ['is_bookmarked'], where: 'id = ?', whereArgs: [verseId], limit: 1);
    if (current.isNotEmpty) {
      int status = current.first['is_bookmarked'] as int;
      int newStatus = status == 1 ? 0 : 1;
      await d.update(
        'verses',
        {'is_bookmarked': newStatus},
        where: 'id = ?',
        whereArgs: [verseId]
      );
    }
  }

  Future<List<VerseModel>> getBookmarkedVerses() async {
    final d = await db;
    final result = await d.query(
      'verses',
      where: 'is_bookmarked = 1',
      orderBy: 'chapter_number ASC, verse_number ASC'
    );
    return result.map((m) => VerseModel.fromMap(m)).toList();
  }
}
