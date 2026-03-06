import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key});

  static const Map<int, Map<String, String>> chapterNames = {
    1: {'sanskrit': 'अर्जुनविषादयोग', 'english': 'Observing the Armies on the Battlefield'},
    2: {'sanskrit': 'सांख्ययोग', 'english': 'Contents of the Gita Summarized'},
    3: {'sanskrit': 'कर्मयोग', 'english': 'Karma-yoga'},
    4: {'sanskrit': 'ज्ञानकर्मसंन्यासयोग', 'english': 'Transcendental Knowledge'},
    5: {'sanskrit': 'कर्मसंन्यासयोग', 'english': 'Karma-yoga Action in Krsna Consciousness'},
    6: {'sanskrit': 'ध्यानयोग', 'english': 'Dhyana-yoga'},
    7: {'sanskrit': 'ज्ञानविज्ञानयोग', 'english': 'Knowledge of the Absolute'},
    8: {'sanskrit': 'अक्षरब्रह्मयोग', 'english': 'Attaining the Supreme'},
    9: {'sanskrit': 'राजविद्याराजगुह्ययोग', 'english': 'The Most Confidential Knowledge'},
    10: {'sanskrit': 'विभूतियोग', 'english': 'The Opulence of the Absolute'},
    11: {'sanskrit': 'विश्वरूपदर्शनयोग', 'english': 'The Universal Form'},
    12: {'sanskrit': 'भक्तियोग', 'english': 'Devotional Service'},
    13: {'sanskrit': 'क्षेत्रक्षेत्रज्ञविभागयोग', 'english': 'Nature, the Enjoyer, and Consciousness'},
    14: {'sanskrit': 'गुणत्रयविभागयोग', 'english': 'The Three Modes of Material Nature'},
    15: {'sanskrit': 'पुरुषोत्तमयोग', 'english': 'The Yoga of the Supreme Person'},
    16: {'sanskrit': 'दैवासुरसम्पद्विभागयोग', 'english': 'The Divine and Demoniac Natures'},
    17: {'sanskrit': 'श्रद्धात्रयविभागयोग', 'english': 'The Divisions of Faith'},
    18: {'sanskrit': 'मोक्षसंन्यासयोग', 'english': 'Conclusion the Perfection of Renunciation'},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
      appBar: AppBar(
        title: const Text('Bhagavad Gita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/gita/search'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => context.push('/gita/bookmarks'),
          ),
        ],
      ),
      body: chaptersAsync.when(
        loading: () => ShimmerLoading.card(count: 5),
        error: (err, stack) => ErrorRetry(
          message: 'Failed to load Gita chapters',
          onRetry: () => ref.invalidate(chaptersProvider),
        ),
        data: (chapters) {
          if (chapters.isEmpty) {
             return const Center(child: Text('Database is currently empty. Run the setup.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chap = chapters[index];
              final chapterNum = chap['chapter_number'] as int;
              final verseCount = chap['verse_count'] as int;
              
              final names = chapterNames[chapterNum] ?? {'sanskrit': '', 'english': 'Chapter $chapterNum'};

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/gita/chapter/$chapterNum'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF00695C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              '$chapterNum',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                names['sanskrit']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'NotoSerifDevanagari'
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                names['english']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.view_headline, color: Colors.white70, size: 16),
                            const SizedBox(height: 4),
                            Text(
                              '$verseCount\nVerses',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
