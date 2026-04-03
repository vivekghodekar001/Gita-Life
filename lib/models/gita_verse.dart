class GitaVerse {
  final int chapter;
  final int verse;
  final String slok;
  final String transliteration;
  final String sivanandaTranslation;
  final String sivanandaCommentary;
  final String hindiTranslation;
  final String purohitTranslation;

  const GitaVerse({
    required this.chapter,
    required this.verse,
    required this.slok,
    required this.transliteration,
    required this.sivanandaTranslation,
    required this.sivanandaCommentary,
    required this.hindiTranslation,
    required this.purohitTranslation,
  });

  factory GitaVerse.fromJson(Map<String, dynamic> json) {
    return GitaVerse(
      chapter: json['chapter'] as int? ?? 0,
      verse: json['verse'] as int? ?? 0,
      slok: json['slok'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      sivanandaTranslation: (json['siva'] as Map<String, dynamic>?)?['et'] as String? ?? '',
      sivanandaCommentary: (json['siva'] as Map<String, dynamic>?)?['ec'] as String? ?? '',
      hindiTranslation: (json['tej'] as Map<String, dynamic>?)?['ht'] as String? ?? '',
      purohitTranslation: (json['purohit'] as Map<String, dynamic>?)?['et'] as String? ?? '',
    );
  }
}

class GitaChapter {
  final int chapterNumber;
  final String name;
  final String translation;
  final String transliteration;
  final String meaningEn;
  final String meaningHi;
  final String summaryEn;
  final String summaryHi;
  final int versesCount;

  const GitaChapter({
    required this.chapterNumber,
    required this.name,
    required this.translation,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningHi,
    required this.summaryEn,
    required this.summaryHi,
    required this.versesCount,
  });

  /// English meaning (for backward compat with UI code using `.meaning`)
  String get meaning => meaningEn;

  factory GitaChapter.fromJson(Map<String, dynamic> json) {
    // meaning can be a String or a Map with en/hi keys
    final meaningRaw = json['meaning'];
    String meaningEn = '';
    String meaningHi = '';
    if (meaningRaw is Map) {
      meaningEn = meaningRaw['en'] as String? ?? '';
      meaningHi = meaningRaw['hi'] as String? ?? '';
    } else if (meaningRaw is String) {
      meaningEn = meaningRaw;
    }

    // summary can be a Map with en/hi keys
    final summaryRaw = json['summary'];
    String summaryEn = '';
    String summaryHi = '';
    if (summaryRaw is Map) {
      summaryEn = summaryRaw['en'] as String? ?? '';
      summaryHi = summaryRaw['hi'] as String? ?? '';
    } else if (summaryRaw is String) {
      summaryEn = summaryRaw;
    }

    return GitaChapter(
      chapterNumber: json['chapter_number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaningEn: meaningEn,
      meaningHi: meaningHi,
      summaryEn: summaryEn,
      summaryHi: summaryHi,
      versesCount: json['verses_count'] as int? ?? 0,
    );
  }
}
