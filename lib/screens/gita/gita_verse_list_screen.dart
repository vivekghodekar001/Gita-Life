import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/sacred_widgets.dart';
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

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF080604),
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x08FFFFFF),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 12, color: SacredColors.parchment.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHAPTER $chapterNumber',
                            style: SacredTextStyles.sectionLabel(fontSize: 8).copyWith(
                              color: SacredColors.parchment.withOpacity(0.4),
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            language == 'en' ? chapterNameEn : chapterNameHi,
                            style: SacredTextStyles.infoValue(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Language switcher
                    Container(
                      decoration: BoxDecoration(
                        color: SacredColors.parchment.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LangPill(
                            text: 'EN',
                            isActive: language == 'en',
                            onTap: () => ref.read(gitaLanguageProvider.notifier).setLanguage('en'),
                          ),
                          _LangPill(
                            text: 'हि',
                            isActive: language == 'hi',
                            onTap: () => ref.read(gitaLanguageProvider.notifier).setLanguage('hi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
=======
      backgroundColor: const Color(0xFFE8F5F9),
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
              ),
              const SizedBox(height: 8),
              // Verse count label
              SacredDivider(),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '$versesCount VERSES',
                      style: SacredTextStyles.sectionLabel(fontSize: 8).copyWith(
                        color: SacredColors.parchment.withOpacity(0.3),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Verse list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: versesCount + 1,
                  itemBuilder: (context, index) {
                    if (index == versesCount) {
                      return _BottomNavButtons(currentChapter: chapterNumber);
                    }
                    final verseNumber = index + 1;
                    return _VerseCardLoader(
                      chapterNumber: chapterNumber,
                      verseNumber: verseNumber,
                      language: language,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseCardLoader extends ConsumerWidget {
  final int chapterNumber;
  final int verseNumber;
  final String language;

  const _VerseCardLoader({
    required this.chapterNumber,
    required this.verseNumber,
    required this.language,
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
              color: SacredColors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SacredColors.parchment.withOpacity(0.06)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$chapterNumber.$verseNumber',
                  style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                    color: SacredColors.parchment.withOpacity(0.5),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                SacredDivider(),
                const SizedBox(height: 10),
                Text(
                  slok,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    'Tiro Devanagari Sanskrit',
                    fontSize: 18,
                    height: 2.0,
                    color: SacredColors.parchmentLight,
                  ),
                ),
                const SizedBox(height: 8),
                SacredDivider(),
                const SizedBox(height: 8),
                Text(
                  transliteration,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: SacredColors.parchment.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 8),
                SacredDivider(),
                const SizedBox(height: 8),
                Text(
                  translation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: 15,
                    color: SacredColors.parchment.withOpacity(0.6),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => SizedBox(height: 200, child: ShimmerLoading.card()),
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

  const _BottomNavButtons({required this.currentChapter});

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
                GestureDetector(
                  onTap: () {
                    final prevCh = chapters[currentChapter - 2];
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GitaVerseListScreen(
                          chapterNumber: prevCh['chapter_number'] ?? 0,
                          chapterNameEn: prevCh['name_translated'] ?? prevCh['name_meaning'] ?? '',
                          chapterNameHi: prevCh['name'] ?? '',
                          versesCount: prevCh['verses_count'] ?? 0,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: SacredColors.glassBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 12, color: SacredColors.parchment.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text('Previous', style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(color: SacredColors.parchment.withOpacity(0.5))),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 100),
                
              if (hasNext)
                GestureDetector(
                  onTap: () {
                    final nextCh = chapters[currentChapter];
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GitaVerseListScreen(
                          chapterNumber: nextCh['chapter_number'] ?? 0,
                          chapterNameEn: nextCh['name_translated'] ?? nextCh['name_meaning'] ?? '',
                          chapterNameHi: nextCh['name'] ?? '',
                          versesCount: nextCh['verses_count'] ?? 0,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: SacredColors.glassBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next', style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(color: SacredColors.parchment.withOpacity(0.5))),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: SacredColors.parchment.withOpacity(0.5)),
                      ],
                    ),
                  ),
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

  const _LangPill({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SacredColors.parchment.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(
            color: isActive ? SacredColors.parchment.withOpacity(0.8) : SacredColors.parchment.withOpacity(0.3),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
