import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gita_provider.dart';
import '../../services/gita_service.dart';
import '../../models/gita_verse.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import 'gita_verse_list_screen.dart';

class VerseListScreen extends ConsumerWidget {
  final String chapterId;

  const VerseListScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterNum = int.tryParse(chapterId) ?? 1;

    // Load chapter info from API to get name and verse count
    return FutureBuilder<GitaChapter>(
      future: GitaService.getChapter(chapterNum),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: ShimmerLoading.card(count: 3)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: ErrorRetry(
                message: 'Failed to load chapter $chapterNum',
                onRetry: () {
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
          );
        }

        final chapter = snapshot.data!;
        return GitaVerseListScreen(
          chapterNumber: chapter.chapterNumber,
          chapterName: chapter.translation.isNotEmpty ? chapter.translation : chapter.meaning,
          versesCount: chapter.versesCount,
        );
      },
    );
  }
}
