import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import 'gita_chapter_list_screen.dart'; // for navigation edge cases

class GitaVerseListScreen extends ConsumerWidget {
  final int chapterNumber;
  final String chapterNameEn;
  final String chapterNameHi;
  final int versesCount;

  const GitaVerseListScreen({
    super.key,
    required this.chapterNumber,
    required this.chapterNameEn,
    required this.chapterNameHi,
    required this.versesCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(gitaLanguageProvider);
    final primaryOrange = const Color(0xFFEA580C);
    
    final chapterTitle = language == 'en' 
        ? 'Chapter $chapterNumber · $chapterNameEn' 
        : 'अध्याय $chapterNumber · $chapterNameHi';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: Text(chapterTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
        actions: [
          // Language Switcher (reusing minimal logic)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   _LangPill(
                    text: 'English',
                    isActive: language == 'en',
                    onTap: () => ref.read(gitaLanguageProvider.notifier).setLanguage('en'),
                    primaryColor: primaryOrange,
                  ),
                  _LangPill(
                    text: 'हिंदी',
                    isActive: language == 'hi',
                    onTap: () => ref.read(gitaLanguageProvider.notifier).setLanguage('hi'),
                    primaryColor: primaryOrange,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      // lazy load verses + 1 extra item for bottom navigation buttons
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: versesCount + 1,
        itemBuilder: (context, index) {
          if (index == versesCount) {
             return _BottomNavButtons(
               currentChapter: chapterNumber, 
               primaryColor: primaryOrange
             );
          }
          final verseNumber = index + 1;
          return _VerseCardLoader(
            chapterNumber: chapterNumber,
            verseNumber: verseNumber,
            language: language,
            primaryColor: primaryOrange,
          );
        },
      ),
    );
  }
}

class _VerseCardLoader extends ConsumerWidget {
  final int chapterNumber;
  final int verseNumber;
  final String language;
  final Color primaryColor;

  const _VerseCardLoader({
    required this.chapterNumber,
    required this.verseNumber,
    required this.language,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheKey = '${chapterNumber}_$verseNumber';
    final verseAsync = ref.watch(gitaApiVerseProvider(cacheKey));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: verseAsync.when(
        data: (verseData) {
          final slok = verseData['slok'] ?? '';
          final transliteration = verseData['transliteration'] ?? '';
          
          String translation = "Translation not available in this language";
          if (language == 'en') {
             translation = verseData['tej']?['et'] ?? verseData['prabhu']?['et'] ?? translation;
          } else if (language == 'hi') {
             translation = verseData['siva']?['ht'] ?? verseData['tej']?['ht'] ?? translation;
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$chapterNumber.$verseNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Divider(color: primaryColor.withOpacity(0.2), thickness: 1, height: 24),
                Text(
                  slok,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    'Tiro Devanagari Sanskrit',
                    fontSize: 18,
                    height: 2.0,
                    color: Colors.black87,
                  ),
                ),
                Divider(color: primaryColor.withOpacity(0.2), thickness: 1, height: 24),
                Text(
                  transliteration,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Divider(color: primaryColor.withOpacity(0.2), thickness: 1, height: 24),
                Text(
                  translation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => ShimmerLoading.card(height: 200),
        error: (err, stack) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ErrorRetry(
              message: 'Failed to load verse $chapterNumber.$verseNumber',
              onRetry: () => ref.refresh(gitaApiVerseProvider(cacheKey)),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButtons extends ConsumerWidget {
  final int currentChapter;
  final Color primaryColor;

  const _BottomNavButtons({required this.currentChapter, required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(gitaApiChaptersProvider);
    
    return chaptersAsync.maybeWhen(
      data: (chapters) {
        final hasPrev = currentChapter > 1;
        final hasNext = currentChapter < 18;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasPrev)
                TextButton.icon(
                  onPressed: () {
                    final prevCh = chapters[currentChapter - 2];
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GitaVerseListScreen(
                          chapterNumber: prevCh['chapter_number'],
                          chapterNameEn: prevCh['translation'],
                          chapterNameHi: prevCh['meaning']['hi'] ?? prevCh['name'],
                          versesCount: prevCh['verses_count'],
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_back, color: primaryColor, size: 18),
                  label: Text('Previous', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                )
              else
                const SizedBox(width: 100), // Placeholder to maintain alignment
                
              if (hasNext)
                TextButton.icon(
                  onPressed: () {
                    final nextCh = chapters[currentChapter]; // next index is currentChapter (since it's 1-based)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GitaVerseListScreen(
                          chapterNumber: nextCh['chapter_number'],
                          chapterNameEn: nextCh['translation'],
                          chapterNameHi: nextCh['meaning']['hi'] ?? nextCh['name'],
                          versesCount: nextCh['verses_count'],
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward, color: primaryColor, size: 18),
                  label: Text('Next', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                )
               else
                const SizedBox(width: 80),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;
  final Color primaryColor;

  const _LangPill({
    required this.text,
    required this.isActive,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? primaryColor : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
