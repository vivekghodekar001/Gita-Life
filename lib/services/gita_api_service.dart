import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GitaApiService {
  final Dio _dio = Dio();
  final Map<String, dynamic> _cache = {};

  Future<List<dynamic>> getChapters() async {
    const cacheKey = 'chapters';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<dynamic>;
    }

    try {
      final response = await _dio.get('https://vedicscriptures.github.io/chapters/');
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }
        final data = rawData as List<dynamic>;
        _cache[cacheKey] = data;
        return data;
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVerse(int chapter, int verse) async {
    final cacheKey = 'verse_${chapter}_$verse';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      final response = await _dio.get('https://vedicscriptures.github.io/slok/$chapter/$verse/');
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }
        final data = rawData as Map<String, dynamic>;
        _cache[cacheKey] = data;
        return data;
      } else {
        throw Exception('Failed to load verse $chapter:$verse - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching verse $chapter:$verse: $e');
      rethrow;
    }
  }
}

final gitaApiServiceProvider = Provider<GitaApiService>((ref) => GitaApiService());
