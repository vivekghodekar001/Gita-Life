import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  print('Initializing sqflite_ffi...');
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = 'assets/db/gita.db';
  final dbFile = File(dbPath);
  
  if (dbFile.existsSync()) {
    print('Deleting existing database at \$dbPath...');
    dbFile.deleteSync();
  } else {
    // Ensure dir exists
    if (!dbFile.parent.existsSync()) {
      dbFile.parent.createSync(recursive: true);
    }
  }

  print('Creating new database at \$dbPath...');
  final db = await databaseFactory.openDatabase(dbPath);

  // Create table schema
  await db.execute('''
    CREATE TABLE verses (
      id INTEGER PRIMARY KEY,
      chapter_number INTEGER NOT NULL,
      verse_number INTEGER NOT NULL,
      text_devanagari TEXT,
      text_transliteration TEXT,
      text_english TEXT,
      purport TEXT,
      is_bookmarked INTEGER DEFAULT 0
    )
  ''');

  print('Table "verses" created.');
  print('Fetching 18 chapters and their verses...');

  // The Gita has 18 chapters. We'll fetch each chapter and then its verses
  // Using bhagavadgitaapi.in API if available
  // Wait, let's fetch chapters first:
  try {
    // Note: Due to rate limits or API structure, we loop from Chapter 1 to 18
    for (int chapterNum = 1; chapterNum <= 18; chapterNum++) {
      print('Fetching verses for Chapter \$chapterNum...');
      final chapterUrl = Uri.parse('https://bhagavadgitaapi.in/chapter/\$chapterNum');
      final chapterRes = await http.get(chapterUrl);
      if (chapterRes.statusCode != 200) {
        throw Exception('Failed to load chapter \$chapterNum');
      }

      final chapterData = jsonDecode(chapterRes.body);
      final versesCount = chapterData['verses_count'] as int;

      for (int verseNum = 1; verseNum <= versesCount; verseNum++) {
        final verseUrl = Uri.parse('https://bhagavadgitaapi.in/slok/\$chapterNum/\$verseNum');
        // Let's retry safely
        int retries = 3;
        dynamic verseData;
        while (retries > 0) {
           final verseRes = await http.get(verseUrl);
           if (verseRes.statusCode == 200) {
              verseData = jsonDecode(verseRes.body);
              break;
           } else {
              retries--;
              print('Retrying verse \$chapterNum:\$verseNum...');
              await Future.delayed(Duration(seconds: 1));
           }
        }
        
        if (verseData == null) {
           print('Failed to pull chapter \$chapterNum verse \$verseNum. Inserting empty placeholders...');
           verseData = {
              'slok': 'Sloka text failed to load',
              'transliteration': '',
              'tej': {'ht': ''}, 
              'siva': {'et': '', 'ec': ''} 
           };
        }

        // Mapping to schema depending on API payload format
        // Expected payload format for bhagavadgitaapi.in parsing logic:
        final devanagari = verseData['slok'] ?? '';
        final transliteration = verseData['transliteration'] ?? '';
        
        // Sometimes English translation is inside siva / purohit / chinmay
        // We'll try to extract primary ones.
        final siva = verseData['siva'];
        final englishText = siva != null ? (siva['et'] ?? '') : '';
        final purportText = siva != null ? (siva['ec'] ?? '') : '';

        // Generate a localized ID matching standard format like 101, 102 ... 1878
        final id = (chapterNum * 1000) + verseNum;

        await db.insert('verses', {
           'id': id,
           'chapter_number': chapterNum,
           'verse_number': verseNum,
           'text_devanagari': devanagari,
           'text_transliteration': transliteration,
           'text_english': englishText,
           'purport': purportText,
           'is_bookmarked': 0
        });
      }
      print('Completed Chapter \$chapterNum (\$versesCount verses).');
    }

    print('Building FTS Virtual table for search queries...');
    await db.execute('''
      CREATE VIRTUAL TABLE verses_fts USING fts5(
        text_devanagari,
        text_transliteration,
        text_english,
        purport,
        content='verses',
        content_rowid='id'
      )
    ''');
    
    // Create trigger to sync FTS table
    await db.execute('''
      CREATE TRIGGER verses_ai AFTER INSERT ON verses BEGIN
        INSERT INTO verses_fts(rowid, text_devanagari, text_transliteration, text_english, purport)
        VALUES (new.id, new.text_devanagari, new.text_transliteration, new.text_english, new.purport);
      END;
    ''');

    // Manually populate FTS with inserted data
    await db.execute('''
        INSERT INTO verses_fts(rowid, text_devanagari, text_transliteration, text_english, purport)
        SELECT id, text_devanagari, text_transliteration, text_english, purport FROM verses;
    ''');

    print('FTS table configured. Db is successfully initialized.');
  } catch (e) {
    print('Db build failed: \$e');
  } finally {
    await db.close();
  }
}
