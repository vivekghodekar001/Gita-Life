import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/audio_provider.dart';
import '../../models/audio_track.dart';
import '../../widgets/audio_mini_player.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

// Category keys must match exactly what's stored in Firestore
const _audioCategoryKeys = ['all', 'bhajan', 'kirtan', 'lecture_audio', 'meditation', 'other'];
const _audioCategoryLabels = {
  'all': 'All',
  'bhajan': 'Bhajans',
  'kirtan': 'Kirtans',
  'lecture_audio': 'Lectures',
  'meditation': 'Meditation',
  'other': 'Other',
};

class _AudioLibraryScreenState extends State<AudioLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final categories = _audioCategoryKeys;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => context.canPop() ? context.pop() : null,
                    ),
                    const Spacer(),
                    Text('AUDIO LIBRARY', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.download_done_rounded, size: 20, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => context.push('/audio/downloads'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Category filter chips — glassmorphism
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _tabController.animateTo(index);
                          setState(() => _selectedIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                              (_audioCategoryLabels[categories[index]] ?? categories[index]).toUpperCase(),
                              style: GoogleFonts.jost(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
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
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: categories.map((c) => _TrackList(category: c)).toList(),
                ),
              ),
              const AudioMiniPlayer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackList extends ConsumerWidget {
  final String category;
  const _TrackList({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryCategory = category == 'all' ? null : category;
    final tracksAsync = ref.watch(audioTracksProvider(queryCategory));
    final downloads = ref.watch(downloadedTracksProvider);

    return tracksAsync.when(
      loading: () => ShimmerLoading.listItem(),
      error: (err, stack) => ErrorRetry(
        message: 'Failed to load audio tracks',
        onRetry: () => ref.invalidate(audioTracksProvider(queryCategory)),
      ),
        data: (rawTracks) {
        // Sort: when viewing All, group by category; within same category sort by title
        final tracks = category == 'all'
            ? ([...rawTracks]..sort((a, b) {
                final catOrder = {'bhajan': 0, 'kirtan': 1, 'lecture_audio': 2, 'meditation': 3, 'other': 4};
                final catCmp = (catOrder[a.category] ?? 9).compareTo(catOrder[b.category] ?? 9);
                return catCmp != 0 ? catCmp : a.title.compareTo(b.title);
              }))
            : rawTracks;
        if (tracks.isEmpty) {
          return Center(
            child: Text(
              'No tracks in this category.',
              style: SacredTextStyles.infoValue().copyWith(color: SacredColors.parchment.withOpacity(0.3)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final isDownloaded = downloads.any((d) => d.trackId == track.trackId);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: SacredDecorations.glassCard(radius: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SacredColors.parchment.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                  ),
                  child: track.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: track.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stack) =>
                                Icon(Icons.music_note_rounded, color: SacredColors.parchment.withOpacity(0.3)),
                          ),
                        )
                      : Icon(Icons.music_note_rounded, color: SacredColors.parchment.withOpacity(0.3)),
                ),
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: SacredColors.parchmentLight.withOpacity(0.8),
                  ),
                ),
                subtitle: Text(
                  track.artist,
                  style: GoogleFonts.jost(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: SacredColors.parchment.withOpacity(0.65),
                  ),
                ),
                trailing: isDownloaded
                    ? Icon(Icons.offline_pin_rounded, color: SacredColors.parchment.withOpacity(0.4), size: 22)
                    : IconButton(
                        icon: Icon(Icons.download_rounded, color: SacredColors.parchment.withOpacity(0.3), size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${track.title}...'),
                              backgroundColor: SacredColors.surface,
                            ),
                          );
                          ref.read(downloadedTracksProvider.notifier).downloadTrack(track);
                        },
                      ),
                onTap: () {
                  ref.read(audioPlayerControllerProvider).playTrack(track, tracks);
                },
              ),
            );
          },
        );
      },
    );
  }
}
