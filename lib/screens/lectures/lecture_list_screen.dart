import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lecture_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class LectureListScreen extends ConsumerWidget {
  const LectureListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    final selectedTopic = ref.watch(lectureTopicProvider);
    final lecturesAsync = ref.watch(filteredLecturesProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => context.canPop() ? context.pop() : null,
                    ),
                    const Spacer(),
                    Text('LECTURES', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar — glassmorphism
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SacredColors.parchment.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                      ),
                      child: TextField(
                        onChanged: (val) => ref.read(lectureSearchQueryProvider.notifier).state = val,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16, color: SacredColors.parchmentLight.withOpacity(0.8),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search lectures by title or topic...',
                          hintStyle: GoogleFonts.cormorantGaramond(
                            fontSize: 15, color: SacredColors.parchment.withOpacity(0.25),
                            fontStyle: FontStyle.italic,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: SacredColors.parchment.withOpacity(0.3), size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Filter Chips — sacred dark
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final isSelected = topic == selectedTopic;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => ref.read(lectureTopicProvider.notifier).state = topic,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? SacredColors.parchment.withOpacity(0.15)
                                : SacredColors.parchment.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? SacredColors.parchment.withOpacity(0.4)
                                  : SacredColors.parchment.withOpacity(0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              topic,
                              style: GoogleFonts.jost(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                                color: isSelected
                                    ? SacredColors.parchmentLight.withOpacity(0.9)
                                    : SacredColors.parchment.withOpacity(0.65),
                              ),
                            ),
                          ),
                        ),
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
                      return Center(
                        child: Text(
                          'No lectures found.',
                          style: SacredTextStyles.infoValue().copyWith(color: SacredColors.parchment.withOpacity(0.3)),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: SacredColors.parchment,
                      backgroundColor: SacredColors.surface,
                      onRefresh: () async => ref.invalidate(filteredLecturesProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: lectures.length,
                        itemBuilder: (context, index) {
                          final lecture = lectures[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: SacredDecorations.glassCard(radius: 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                ref.read(lectureServiceProvider).incrementViewCount(lecture.lectureId);
                                context.push('/lectures/player/${lecture.lectureId}', extra: lecture);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: lecture.thumbnailUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: lecture.thumbnailUrl!,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, err) => _placeholderThumbnail(),
                                          )
                                        : _placeholderThumbnail(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Text(
                                      lecture.title,
                                      style: GoogleFonts.cormorantGaramond(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: SacredColors.parchmentLight.withOpacity(0.8),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
        ),
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      height: 180,
      width: double.infinity,
      color: SacredColors.surface,
      child: Center(
        child: Icon(Icons.play_circle_fill_rounded, size: 52, color: SacredColors.parchment.withOpacity(0.15)),
      ),
    );
  }
}
