import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/audio_provider.dart';
import '../../models/audio_track.dart';
import '../../widgets/audio_mini_player.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final categories = ['All', 'Bhajans', 'Kirtans', 'Lectures'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Audio Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done),
            onPressed: () => context.push('/audio/downloads'),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFF6600),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6600),
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((c) => _TrackList(category: c)).toList(),
            ),
          ),
          const AudioMiniPlayer(),
        ],
      ),
    );
  }
}

class _TrackList extends ConsumerWidget {
  final String category;
  const _TrackList({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryCategory = category == 'All' ? null : category;
    final tracksAsync = ref.watch(audioTracksProvider(queryCategory));
    final downloads = ref.watch(downloadedTracksProvider);

    return tracksAsync.when(
      loading: () => ShimmerLoading.listItem(),
      error: (err, stack) => ErrorRetry(
        message: 'Failed to load audio tracks',
        onRetry: () => ref.invalidate(audioTracksProvider(queryCategory)),
      ),
      data: (tracks) {
        if (tracks.isEmpty) return const Center(child: Text('No tracks found in this category.'));
        
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final isDownloaded = downloads.any((d) => d.trackId == track.trackId);
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: track.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                           imageUrl: track.coverImageUrl!, 
                           fit: BoxFit.cover,
                           errorWidget: (context, error, stack) => const Icon(Icons.music_note, color: Colors.orange),
                        ),
                      )
                    : const Icon(Icons.music_note, color: Colors.orange),
              ),
              title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                 style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(track.artist, style: TextStyle(color: Colors.grey.shade600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (isDownloaded)
                      const Icon(Icons.offline_pin, color: Colors.green, size: 24)
                   else
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blueGrey),
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading \${track.title}...')));
                           ref.read(downloadedTracksProvider.notifier).downloadTrack(track);
                        },
                      ),
                ],
              ),
              onTap: () {
                ref.read(audioPlayerControllerProvider).playTrack(track, tracks);
              },
            );
          },
        );
      },
    );
  }
}
