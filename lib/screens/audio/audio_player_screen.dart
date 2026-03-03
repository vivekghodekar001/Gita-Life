import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/audio_provider.dart';

class AudioPlayerScreen extends ConsumerWidget {
  final String trackId;

  const AudioPlayerScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrack = ref.watch(activeTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final speedAsync = ref.watch(speedProvider);
    final shuffleAsync = ref.watch(shuffleModeProvider);
    final loopAsync = ref.watch(loopModeProvider);
    final downloads = ref.watch(downloadedTracksProvider);

    if (activeTrack == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No active track')),
      );
    }

    final isPlaying = isPlayingAsync.value ?? false;
    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;
    final speed = speedAsync.value ?? 1.0;
    final isShuffle = shuffleAsync.value ?? false;
    final loopMode = loopAsync.value ?? LoopMode.off;
    final isDownloaded = downloads.any((d) => d.trackId == activeTrack.trackId);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.blueGrey),
          onPressed: () => context.pop(),
        ),
        actions: [
           if (isDownloaded)
             const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.offline_pin, color: Colors.green))
           else
             IconButton(
               icon: const Icon(Icons.download, color: Colors.blueGrey),
               onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading \${activeTrack.title}...')));
                 ref.read(downloadedTracksProvider.notifier).downloadTrack(activeTrack);
               },
             ),
           IconButton(
             icon: const Icon(Icons.share, color: Colors.blueGrey),
             onPressed: () {
               Share.share('Check out \${activeTrack.title} on GitaLife!');
             },
           )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // Cover Art
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: activeTrack.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: activeTrack.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, err) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            const SizedBox(height: 40),
            
            // Info
            Text(
              activeTrack.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              activeTrack.artist,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Progress Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFFF6600),
                inactiveTrackColor: Colors.orange.shade100,
                thumbColor: const Color(0xFFFF6600),
                trackHeight: 6,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                min: 0,
                max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
                value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1),
                onChanged: (val) {
                  ref.read(audioPlayerControllerProvider).seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
            // Time Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position), style: TextStyle(color: Colors.grey.shade600)),
                  Text(_formatDuration(duration), style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.shuffle, color: isShuffle ? const Color(0xFFFF6600) : Colors.blueGrey),
                  onPressed: () => ref.read(audioPlayerControllerProvider).toggleShuffle(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40, color: Colors.blueGrey),
                  onPressed: () => ref.read(audioPlayerControllerProvider).previous(),
                ),
                GestureDetector(
                  onTap: () => ref.read(audioPlayerControllerProvider).togglePlay(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6600),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40, color: Colors.blueGrey),
                  onPressed: () => ref.read(audioPlayerControllerProvider).next(),
                ),
                IconButton(
                  icon: Icon(
                    loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                    color: loopMode != LoopMode.off ? const Color(0xFFFF6600) : Colors.blueGrey,
                  ),
                  onPressed: () => ref.read(audioPlayerControllerProvider).toggleLoop(),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Speed & Volume row (Volume might not be supported natively on all mobile without system overrides, exposing internal stream volume if necessary, otherwise skipping native volume since OS manages it)
            // We will expose Speed.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, color: Colors.blueGrey),
                const SizedBox(width: 10),
                DropdownButton<double>(
                  value: speed,
                  items: [0.75, 1.0, 1.25, 1.5, 2.0].map((s) => DropdownMenuItem(value: s, child: Text('\${s}x'))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(audioPlayerControllerProvider).setSpeed(val);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '\$minutes:\$seconds';
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.orange.shade100,
      child: const Icon(Icons.music_note, color: Colors.orange, size: 100),
    );
  }
}
