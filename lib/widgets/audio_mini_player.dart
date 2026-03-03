import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/audio_provider.dart';

class AudioMiniPlayer extends ConsumerWidget {
  const AudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrack = ref.watch(activeTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);

    if (activeTrack == null) return const SizedBox.shrink();

    final isPlaying = isPlayingAsync.value ?? false;

    return GestureDetector(
      onTap: () => context.push('/audio/player/\${activeTrack.trackId}'),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            if (activeTrack.coverImageUrl != null)
              CachedNetworkImage(
                imageUrl: activeTrack.coverImageUrl!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholderImage(),
              )
            else
              _placeholderImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeTrack.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    activeTrack.artist,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
              color: const Color(0xFFFF6600),
              onPressed: () {
                ref.read(audioPlayerControllerProvider).togglePlay();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.orange.shade100,
      child: const Icon(Icons.music_note, color: Colors.orange, size: 30),
    );
  }
}
