import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gita_provider.dart';
import '../../app/sacred_theme.dart';

class VerseListScreen extends ConsumerWidget {
  final String chapterId;

  const VerseListScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterNum = int.tryParse(chapterId) ?? 1;
    final versesAsync = ref.watch(versesByChapterProvider(chapterNum));

    return Scaffold(
      backgroundColor: SacredColors.ink,
      appBar: AppBar(
        title: Text('Chapter $chapterNum'),
      ),
      body: versesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (verses) {
          if (verses.isEmpty) {
            return const Center(child: Text('No verses found for this chapter.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: verses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Dismissible(
                key: Key('verse_${verse.id}'),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.bookmark_add, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.bookmark_remove, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                   await ref.read(gitaServiceProvider).toggleBookmark(verse.id);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(
                       verse.isBookmarked ? 'Bookmark Removed' : 'Verse Bookmarked'
                     ))
                   );
                   // Invalidate locally so bookmark caches refresh
                   ref.invalidate(bookmarkedVersesProvider);
                   return false; // Don't actually swipe it off screen visually
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1565C0).withOpacity(0.2),
                    child: Text(
                      '${verse.verseNumber}',
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    verse.textDevanagari.split('\\n').first,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSerifDevanagari',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    verse.textTransliteration.split('\\n').first,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: verse.isBookmarked ? const Icon(Icons.bookmark, color: Color(0xFF1565C0)) : null,
                  onTap: () {
                    context.push('/gita/chapter/$chapterNum/verse/${verse.verseNumber}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
