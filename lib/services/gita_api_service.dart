import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GitaApiService {
  final Dio _dio = Dio();
  final Map<String, dynamic> _cache = {};

  // You must set this key in your environment or directly here to use the API
  static const String _rapidApiKey = '1ad30eb63bmsh755e2d359f301d9p183328jsn668afcd236fd'; 
  
  Options get _options => Options(
    headers: {
      'X-RapidAPI-Key': _rapidApiKey,
      'X-RapidAPI-Host': 'bhagavad-gita3.p.rapidapi.com',
    },
    validateStatus: (status) => status! < 500, // Handle 4xx gracefully
  );

  Future<List<dynamic>> getChapters() async {
    const cacheKey = 'chapters';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<dynamic>;
    }

    try {
      final response = await _dio.get(
        'https://bhagavad-gita3.p.rapidapi.com/v2/chapters/',
        options: _options,
      );
      
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) rawData = jsonDecode(rawData);
        
        final data = rawData as List<dynamic>;
        _cache[cacheKey] = data;
        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
         throw Exception('Invalid RapidAPI Key. Please insert your key in GitaApiService.');
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
      final response = await _dio.get(
        'https://bhagavad-gita3.p.rapidapi.com/v2/chapters/$chapter/verses/$verse/',
        options: _options,
      );
      
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) rawData = jsonDecode(rawData);
        
        // The RapidAPI returns a slightly different structure,
        // so we map it back to what our existing UI expects.
        final map = rawData as Map<String, dynamic>;
        
        // Extract translations safely
        String? enTranslation;
        String? hiTranslation;
        
        final translations = map['translations'] as List<dynamic>? ?? [];
        for (var t in translations) {
          if (t['language'] == 'english') enTranslation ??= t['description'];
          if (t['language'] == 'hindi') hiTranslation ??= t['description'];
        }

        final normalizedData = {
          'slok': map['text'] ?? '',
          'transliteration': map['transliteration'] ?? '',
          'tej': {
            'et': enTranslation,
            'ht': hiTranslation,
          }
        };
        
        _cache[cacheKey] = normalizedData;
        return normalizedData;
        
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
