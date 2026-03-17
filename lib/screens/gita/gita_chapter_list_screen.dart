import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../models/gita_verse.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/sacred_widgets.dart';

class GitaChapterListScreen extends ConsumerWidget {
  const GitaChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
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
                          color: const Color(0xFF8B6914).withOpacity(0.08),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 12, color: SacredColors.parchment.withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('BHAGAVAD GITA', style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(color: SacredColors.parchment.withOpacity(0.6), letterSpacing: 4)),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: chaptersAsync.when(
                  data: (chapters) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return _ChapterListTile(
                          chapter: chapter,
                          onTap: () {
                            context.push('/gita/chapter/${chapter.chapterNumber}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 8,
                    itemBuilder: (context, index) => ShimmerLoading.card(),
                  ),
                  error: (err, stack) => Center(
                    child: ErrorRetry(
                      message: 'Failed to load chapters:\n$err',
                      onRetry: () => ref.invalidate(chaptersProvider),
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

class _ChapterListTile extends StatelessWidget {
  final GitaChapter chapter;
  final VoidCallback onTap;

  const _ChapterListTile({
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chNum = chapter.chapterNumber.toString();
    final nameEn = chapter.translation.isNotEmpty ? chapter.translation : chapter.meaning;
    final nameSa = chapter.name;
    final verses = chapter.versesCount.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4)],
          ),
          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4A2C0A).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Chapter number circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8B4513).withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  chNum,
                  style: GoogleFonts.cormorantSc(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF5E8D0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Chapter details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameEn,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A2010),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nameSa,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF8B6914).withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Verse count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B6914).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2)),
              ),
              child: Text(
                verses,
                style: GoogleFonts.jost(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B4513).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: const Color(0xFF8B6914).withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
