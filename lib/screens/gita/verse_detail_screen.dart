import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/gita_provider.dart';

// Provides local state for adjustable font sizing
final fontSizeProvider = StateProvider<double>((ref) => 18.0);

class VerseDetailScreen extends ConsumerWidget {
  final String chapterId;
  final String verseId;

  const VerseDetailScreen({
    super.key,
    required this.chapterId,
    required this.verseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterNum = int.tryParse(chapterId) ?? 1;
    final verseNum = int.tryParse(verseId) ?? 1;

    // We can fetch the whole chapter and find the current one, 
    // This allows next/prev logic easily without extra querying
    final versesAsync = ref.watch(versesByChapterProvider(chapterNum));
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('BG $chapterNum.$verseNum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              if (fontSize > 12) ref.read(fontSizeProvider.notifier).state -= 2;
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              if (fontSize < 36) ref.read(fontSizeProvider.notifier).state += 2;
            },
          ),
        ],
      ),
      body: versesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (verses) {
          if (verses.isEmpty) return const Center(child: Text('Verse not found.'));

          final index = verses.indexWhere((v) => v.verseNumber == verseNum);
          if (index == -1) return const Center(child: Text('Verse not found in chapter.'));
          
          final verse = verses[index];
          final hasNext = index < verses.length - 1;
          final hasPrev = index > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFFFF6600),
                        size: 30,
                      ),
                      onPressed: () async {
                        await ref.read(gitaServiceProvider).toggleBookmark(verse.id);
                        ref.invalidate(versesByChapterProvider(chapterNum));
                        ref.invalidate(bookmarkedVersesProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blueGrey, size: 28),
                      onPressed: () {
                        Share.share(
                          'Bhagavad Gita ${verse.chapterNumber}.${verse.verseNumber}\n\n${verse.textDevanagari}\n\n${verse.textEnglish}\n\nShared via GitaLife App',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Devanagari
                Text(
                  verse.textDevanagari.replaceAll('\\r\\n', '\\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize + 6,
                    color: const Color(0xFFFF6600),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSerifDevanagari',
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Transliteration
                Text(
                  verse.textTransliteration.replaceAll('\\r\\n', '\\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // English Translation
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Translation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.textEnglish,
                  style: TextStyle(fontSize: fontSize, height: 1.6),
                ),
                const SizedBox(height: 24),

                // Purport (if exists)
                if (verse.purport.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Purport',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verse.purport,
                    style: TextStyle(fontSize: fontSize - 1, height: 1.6),
                  ),
                ],

                const SizedBox(height: 40),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasPrev)
                      ElevatedButton.icon(
                        onPressed: () => context.pushReplacement('/gita/chapter/$chapterNum/verse/${verseNum - 1}'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),
                      
                    if (hasNext)
                      ElevatedButton.icon(
                        onPressed: () => context.pushReplacement('/gita/chapter/$chapterNum/verse/${verseNum + 1}'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
