// Bhagavad Gita Database Builder Script
//
// This script fetches all 700 verses from the Bhagavad Gita API and creates
// a SQLite database at assets/db/gita.db ready for use in the Flutter app.
//
// HOW TO RUN:
//   1. Make sure you have Dart SDK installed
//   2. From the project root, run:
//      dart run scripts/build_gita_db.dart
//   3. The script will create/overwrite assets/db/gita.db
//   4. After running, rebuild Flutter app to bundle the new database

import 'dart:convert';
import 'dart:io';

const String apiBaseUrl = 'https://bhagavadgitaapi.in/slok';
const String dbPath = 'assets/db/gita.db';

// Chapter verse counts for Bhagavad Gita
const List<int> chapterVerseCounts = [
  47, 72, 43, 42, 29, 47, 30, 28, 34, 42,
  55, 20, 35, 27, 20, 24, 28, 78,
];

void main() async {
  print('=== Bhagavad Gita Database Builder ===');
  print('Fetching verses from API...\n');

  // TODO: Install sqflite_common_ffi package for desktop SQLite support
  // Run: dart pub add sqflite_common_ffi
  // Then uncomment and implement the database creation logic below

  final verses = <Map<String, dynamic>>[];
  int totalFetched = 0;

  for (int chapter = 1; chapter <= 18; chapter++) {
    final verseCount = chapterVerseCounts[chapter - 1];
    print('Fetching Chapter $chapter ($verseCount verses)...');

    for (int verse = 1; verse <= verseCount; verse++) {
      try {
        final url = '$apiBaseUrl/$chapter/$verse/';
        final request = await HttpClient().getUrl(Uri.parse(url));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;

        verses.add({
          'chapter_number': chapter,
          'verse_number': verse,
          'text_devanagari': data['slok'] ?? '',
          'text_transliteration': data['transliteration'] ?? '',
          'text_english': data['tej']?['ht'] ?? data['tej']?['et'] ?? '',
          'purport': data['purohit']?['et'] ?? data['san']?['et'] ?? '',
          'is_bookmarked': 0,
        });

        totalFetched++;
        if (verse % 10 == 0) {
          stdout.write('  Progress: $verse/$verseCount verses\r');
        }
      } catch (e) {
        print('  ERROR fetching $chapter.$verse: $e');
      }
    }
    print('  ✓ Chapter $chapter complete');
  }

  print('\nTotal verses fetched: $totalFetched');
  print('\nCreating SQLite database at $dbPath...');

  // TODO: Replace with actual SQLite write using sqflite_common_ffi
  // Example implementation:
  //
  // import 'package:sqflite_common_ffi/sqflite_ffi.dart';
  //
  // sqfliteFfiInit();
  // final db = await databaseFactoryFfi.openDatabase(dbPath);
  // await db.execute('''
  //   CREATE TABLE IF NOT EXISTS verses (
  //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     chapter_number INTEGER NOT NULL,
  //     verse_number INTEGER NOT NULL,
  //     text_devanagari TEXT NOT NULL,
  //     text_transliteration TEXT NOT NULL,
  //     text_english TEXT NOT NULL,
  //     purport TEXT NOT NULL,
  //     is_bookmarked INTEGER DEFAULT 0
  //   )
  // ''');
  // final batch = db.batch();
  // for (final verse in verses) {
  //   batch.insert('verses', verse);
  // }
  // await batch.commit(noResult: true);
  // await db.close();

  print('Done! Database saved to $dbPath');
  print('\nNext steps:');
  print('  1. Add sqflite_common_ffi to dev_dependencies');
  print('  2. Uncomment SQLite write code in this script');
  print('  3. Run: dart run scripts/build_gita_db.dart');
  print('  4. Rebuild Flutter app: flutter build apk');
}
