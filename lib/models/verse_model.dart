class VerseModel {
  final int id;
  final int chapterNumber;
  final int verseNumber;
  final String textDevanagari;
  final String textTransliteration;
  final String textEnglish;
  final String purport;
  final bool isBookmarked;

  const VerseModel({
    required this.id,
    required this.chapterNumber,
    required this.verseNumber,
    required this.textDevanagari,
    required this.textTransliteration,
    required this.textEnglish,
    required this.purport,
    this.isBookmarked = false,
  });

  factory VerseModel.fromMap(Map<String, dynamic> map) {
    return VerseModel(
      id: map['id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      textDevanagari: map['text_devanagari'] as String,
      textTransliteration: map['text_transliteration'] as String,
      textEnglish: map['text_english'] as String,
      purport: map['purport'] as String,
      isBookmarked: (map['is_bookmarked'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text_devanagari': textDevanagari,
      'text_transliteration': textTransliteration,
      'text_english': textEnglish,
      'purport': purport,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  VerseModel copyWith({
    int? id,
    int? chapterNumber,
    int? verseNumber,
    String? textDevanagari,
    String? textTransliteration,
    String? textEnglish,
    String? purport,
    bool? isBookmarked,
  }) {
    return VerseModel(
      id: id ?? this.id,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      textDevanagari: textDevanagari ?? this.textDevanagari,
      textTransliteration: textTransliteration ?? this.textTransliteration,
      textEnglish: textEnglish ?? this.textEnglish,
      purport: purport ?? this.purport,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
