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
  final String meaning;
  final int versesCount;

  const GitaChapter({
    required this.chapterNumber,
    required this.name,
    required this.translation,
    required this.meaning,
    required this.versesCount,
  });

  factory GitaChapter.fromJson(Map<String, dynamic> json) {
    return GitaChapter(
      chapterNumber: json['chapter_number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      meaning: json['meaning'] as String? ?? json['name_meaning'] as String? ?? '',
      versesCount: json['verses_count'] as int? ?? 0,
    );
  }
}
