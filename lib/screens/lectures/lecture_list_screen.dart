import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/lecture_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class LectureListScreen extends ConsumerWidget {
  const LectureListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    final selectedTopic = ref.watch(lectureTopicProvider);
    final lecturesAsync = ref.watch(filteredLecturesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Multimedia Lectures'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(lectureSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search lectures by title or topic...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6600)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                final isSelected = topic == selectedTopic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFF6600),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      ref.read(lectureTopicProvider.notifier).state = topic;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Lectures List
          Expanded(
            child: lecturesAsync.when(
              loading: () => ShimmerLoading.card(),
              error: (err, stack) => ErrorRetry(
                message: 'Failed to load lectures',
                onRetry: () => ref.invalidate(filteredLecturesProvider),
              ),
              data: (lectures) {
                if (lectures.isEmpty) {
                  return const Center(child: Text('No lectures found.', style: TextStyle(color: Colors.blueGrey, fontSize: 16)));
                }
                return RefreshIndicator(
                  color: const Color(0xFFFF6600),
                  onRefresh: () async => ref.invalidate(filteredLecturesProvider),
                  child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    final lecture = lectures[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          ref.read(lectureServiceProvider).incrementViewCount(lecture.lectureId);
                          context.push('/lectures/player/${lecture.lectureId}', extra: lecture);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: lecture.thumbnailUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: lecture.thumbnailUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, err) => _placeholderThumbnail(),
                                    )
                                  : _placeholderThumbnail(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lecture.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Only Title as requested
                                  const SizedBox(height: 4),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.orange.shade100,
      child: const Center(
        child: Icon(Icons.play_circle_fill, size: 64, color: Colors.orange),
      ),
    );
  }
}
