import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/sacred_widgets.dart';
import 'gita_verse_list_screen.dart';

class GitaChapterListScreen extends ConsumerWidget {
  const GitaChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(gitaLanguageProvider);
    final chaptersAsync = ref.watch(gitaApiChaptersProvider);
    
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
=======
      backgroundColor: const Color(0xFFE8F5F9), // Warm background
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: const Text('Bhagavad Gita', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Language Switcher Pills
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
                    onTap: () {
                      if (language != 'en') ref.read(gitaLanguageProvider.notifier).toggle();
                    },
                    primaryColor: primaryOrange,
                  ),
                  _LangPill(
                    text: 'हिंदी',
                    isActive: language == 'hi',
                    onTap: () {
                      if (language != 'hi') ref.read(gitaLanguageProvider.notifier).toggle();
                    },
                    primaryColor: primaryOrange,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _ChapterCard(
                chapter: chapter, 
                primaryColor: primaryOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GitaVerseListScreen(
                        chapterNumber: chapter['chapter_number'] ?? 0,
                        chapterNameEn: chapter['name_translated'] ?? chapter['name_meaning'] ?? '',
                        chapterNameHi: chapter['name'] ?? '',
                        versesCount: chapter['verses_count'] ?? 0,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('BHAGAVAD GITA', style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(color: SacredColors.parchment.withOpacity(0.5), letterSpacing: 4)),
                    const Spacer(),
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
                            onTap: () {
                              if (language != 'en') ref.read(gitaLanguageProvider.notifier).toggle();
                            },
                          ),
                          _LangPill(
                            text: 'हि',
                            isActive: language == 'hi',
                            onTap: () {
                              if (language != 'hi') ref.read(gitaLanguageProvider.notifier).toggle();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: chaptersAsync.when(
                  data: (chapters) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return _ChapterCard(
                          chapter: chapter,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GitaVerseListScreen(
                                  chapterNumber: chapter['chapter_number'] ?? 0,
                                  chapterNameEn: chapter['name_translated'] ?? chapter['name_meaning'] ?? '',
                                  chapterNameHi: chapter['name'] ?? '',
                                  versesCount: chapter['verses_count'] ?? 0,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) => ShimmerLoading.grid(),
                  ),
                  error: (err, stack) => Center(
                    child: ErrorRetry(
                      message: 'Failed to load chapters:\n$err',
                      onRetry: () => ref.refresh(gitaApiChaptersProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chNum = chapter['chapter_number']?.toString() ?? '';
    final nameEn = chapter['name_translated'] ?? chapter['name_meaning'] ?? '';
    final nameSa = chapter['name'] ?? '';
    final verses = (chapter['verses_count'] ?? 0).toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SacredColors.glassBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SacredColors.parchment.withOpacity(0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chNum,
                style: GoogleFonts.cormorantSc(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: SacredColors.parchment.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nameEn,
                textAlign: TextAlign.center,
                style: SacredTextStyles.infoValue(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                nameSa,
                textAlign: TextAlign.center,
                style: SacredTextStyles.greeting(fontSize: 11).copyWith(
                  color: SacredColors.parchment.withOpacity(0.35),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: SacredColors.parchment.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                ),
                child: Text(
                  '$verses verses',
                  style: SacredTextStyles.sectionLabel(fontSize: 7).copyWith(
                    color: SacredColors.parchment.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
