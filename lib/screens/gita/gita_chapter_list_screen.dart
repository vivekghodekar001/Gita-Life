import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import 'gita_verse_list_screen.dart'; // We will create this next

class GitaChapterListScreen extends ConsumerWidget {
  const GitaChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(gitaLanguageProvider);
    final chaptersAsync = ref.watch(gitaApiChaptersProvider);
    
    const Color primaryOrange = Color(0xFFEA580C);

    return Scaffold(
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chNum = chapter['chapter_number']?.toString() ?? '';
    final nameEn = chapter['name_translated'] ?? chapter['name_meaning'] ?? '';
    final nameSa = chapter['name'] ?? '';
    final verses = (chapter['verses_count'] ?? 0).toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chNum,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nameEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                nameSa,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$verses verses',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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
