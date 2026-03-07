import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gita_provider.dart';
import '../../app/sacred_theme.dart';

final gitaSearchQueryProvider = StateProvider<String>((ref) => '');

class GitaSearchScreen extends ConsumerWidget {
  const GitaSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(gitaSearchQueryProvider);
    final searchResults = ref.watch(gitaSearchProvider(query));

    return Scaffold(
      backgroundColor: SacredColors.ink,
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search verses (english, sanskrit)...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (val) {
             ref.read(gitaSearchQueryProvider.notifier).state = val;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(gitaSearchQueryProvider.notifier).state = '';
              },
            )
        ],
      ),
      body: query.isEmpty
          ? const Center(
              child: Text(
                'Type to explore the Bhagavad Gita...',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: \$err')),
              data: (verses) {
                if (verses.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: verses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        'BG \${verse.chapterNumber}.\${verse.verseNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            verse.textDevanagari.split('\\n').first,
                            style: const TextStyle(fontFamily: 'NotoSerifDevanagari', fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            verse.textEnglish,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          )
                        ],
                      ),
                      onTap: () {
                        context.push('/gita/chapter/\${verse.chapterNumber}/verse/\${verse.verseNumber}');
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
