import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/gita_verse.dart';

class GitaService {
  static const String _baseUrl = 'https://vedicscriptures.github.io';

  static final Map<String, dynamic> _cache = {};

  static Future<GitaVerse> getVerse(int chapter, int verse) async {
    final cacheKey = 'verse_${chapter}_$verse';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as GitaVerse;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/slok/$chapter/$verse'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final gitaVerse = GitaVerse.fromJson(json);
        _cache[cacheKey] = gitaVerse;
        return gitaVerse;
      } else {
        throw Exception('Failed to load verse $chapter:$verse (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching verse $chapter:$verse: $e');
      rethrow;
    }
  }

  static Future<GitaChapter> getChapter(int chapter) async {
    final cacheKey = 'chapter_$chapter';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as GitaChapter;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/chapter/$chapter'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final gitaChapter = GitaChapter.fromJson(json);
        _cache[cacheKey] = gitaChapter;
        return gitaChapter;
      } else {
        throw Exception('Failed to load chapter $chapter (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching chapter $chapter: $e');
      rethrow;
    }
  }

  static Future<List<GitaChapter>> getAllChapters() async {
    const cacheKey = 'all_chapters';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<GitaChapter>;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/chapters'));
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        final chapters = jsonList
            .map((json) => GitaChapter.fromJson(json as Map<String, dynamic>))
            .toList();
        _cache[cacheKey] = chapters;
        return chapters;
      } else {
        throw Exception('Failed to load chapters (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
      rethrow;
    }
  }
}
