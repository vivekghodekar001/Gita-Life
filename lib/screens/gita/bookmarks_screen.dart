import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gita_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedVersesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Bookmarked Verses'),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
        data: (verses) {
          if (verses.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarks yet.\nSwipe a verse to bookmark it!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: verses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Dismissible(
                key: Key('bookmark_${verse.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref.read(gitaServiceProvider).toggleBookmark(verse.id);
                  // Since we are removing, invalidate cache
                  ref.invalidate(bookmarkedVersesProvider);
                  // Also invalidate chapter if recently visited
                  ref.invalidate(versesByChapterProvider(verse.chapterNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark removed'))
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    'Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6600)),
                  ),
                  subtitle: Text(
                    verse.textEnglish,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/gita/chapter/${verse.chapterNumber}/verse/${verse.verseNumber}');
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
