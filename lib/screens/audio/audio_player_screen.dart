import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/audio_provider.dart';
import '../../models/audio_track.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final String trackId;

  const AudioPlayerScreen({super.key, required this.trackId});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _ytController;
  late AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _discController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: SacredColors.ink,
        body: SacredBackground(
          child: Center(child: Text('No active track', style: SacredTextStyles.infoValue())),
        ),
      );
    }

    final isPlaying = isPlayingAsync.value ?? false;
    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;
    final speed = speedAsync.value ?? 1.0;
    final isShuffle = shuffleAsync.value ?? false;
    final loopMode = loopAsync.value ?? LoopMode.off;
    final isDownloaded = downloads.any((d) => d.trackId == activeTrack.trackId);
    final isYouTube = activeTrack.sourceType == 'youtube';

    // Control disc rotation
    if (isPlaying && !isYouTube) {
      _discController.repeat();
    } else {
      _discController.stop();
    }

    if (isYouTube && _ytController == null) {
      _ytController = YoutubePlayerController(
        initialVideoId: activeTrack.streamUrl ?? '',
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    }

<<<<<<< HEAD
    // Get recommendations (other tracks from same provider)
    final allTracks = ref.watch(audioTracksProvider(null));
    final recommendations = allTracks.whenData((tracks) {
      final others = tracks.where((t) => t.trackId != activeTrack.trackId).toList();
      others.shuffle(Random());
      return others.take(6).toList();
    });

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
=======
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
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
           else if (!isYouTube)
             IconButton(
               icon: const Icon(Icons.download, color: Colors.blueGrey),
               onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${activeTrack.title}...')));
                 ref.read(downloadedTracksProvider.notifier).downloadTrack(activeTrack);
               },
             ),
           IconButton(
             icon: const Icon(Icons.share, color: Colors.blueGrey),
             onPressed: () {
               Share.share('Check out ${activeTrack.title} on GitaLife!');
             },
           )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // Cover Art / Video
            Container(
              height: isYouTube ? 220 : 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: isYouTube && _ytController != null
                  ? YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: true,
                      onReady: () {
                        // Pause just_audio if it was playing
                        ref.read(audioPlayerControllerProvider).stop();
                      },
                    )
                  : (activeTrack.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: activeTrack.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, err) => _placeholderImage(),
                      )
                    : _placeholderImage()),
              ),
            ),
            const SizedBox(height: 30),
            
            // Info
            Text(
              activeTrack.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              activeTrack.artist,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isYouTube ? 20 : 30),

            if (!isYouTube) ...[
              // Progress Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF1565C0),
                  inactiveTrackColor: const Color(0xFFE8F5F9),
                  thumbColor: const Color(0xFF1565C0),
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    Text('NOW PLAYING', style: SacredTextStyles.sectionLabel(fontSize: 9)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.4)),
                      onPressed: () => Share.share('Check out ${activeTrack.title} on GitaLife!'),
                    ),
                  ],
                ),
              ),

<<<<<<< HEAD
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Rotating Disc or YouTube player
                      if (isYouTube && _ytController != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: YoutubePlayer(
                            controller: _ytController!,
                            showVideoProgressIndicator: true,
                            onReady: () => ref.read(audioPlayerControllerProvider).stop(),
                          ),
                        )
                      else
                        _RotatingDisc(
                          controller: _discController,
                          imageUrl: activeTrack.coverImageUrl,
                          size: 220,
                        ),

                      const SizedBox(height: 28),

                      // Track info
                      Text(
                        activeTrack.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: SacredColors.parchmentLight.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
=======
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, color: isShuffle ? const Color(0xFF1565C0) : Colors.blueGrey),
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
                        color: Color(0xFF1565C0),
                        shape: BoxShape.circle,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeTrack.artist,
                        style: GoogleFonts.jost(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: SacredColors.parchment.withOpacity(0.35),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (!isYouTube) ...[
                        const SizedBox(height: 28),

                        // Progress slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: SacredColors.parchment.withOpacity(0.5),
                            inactiveTrackColor: SacredColors.parchment.withOpacity(0.08),
                            thumbColor: SacredColors.parchment.withOpacity(0.7),
                            trackHeight: 3,
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          ),
                          child: Slider(
                            min: 0,
                            max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
                            value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1),
                            onChanged: (val) => ref.read(audioPlayerControllerProvider).seek(Duration(milliseconds: val.toInt())),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position), style: GoogleFonts.jost(fontSize: 11, color: SacredColors.parchment.withOpacity(0.25), fontWeight: FontWeight.w300)),
                              Text(_formatDuration(duration), style: GoogleFonts.jost(fontSize: 11, color: SacredColors.parchment.withOpacity(0.25), fontWeight: FontWeight.w300)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Playback controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.shuffle_rounded, size: 20,
                                  color: isShuffle ? SacredColors.parchment.withOpacity(0.7) : SacredColors.parchment.withOpacity(0.2)),
                              onPressed: () => ref.read(audioPlayerControllerProvider).toggleShuffle(),
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_previous_rounded, size: 32, color: SacredColors.parchment.withOpacity(0.5)),
                              onPressed: () => ref.read(audioPlayerControllerProvider).previous(),
                            ),
                            // Play/Pause
                            GestureDetector(
                              onTap: () => ref.read(audioPlayerControllerProvider).togglePlay(),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SacredColors.parchment.withOpacity(0.12),
                                  border: Border.all(color: SacredColors.parchment.withOpacity(0.3)),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 32,
                                  color: SacredColors.parchmentLight.withOpacity(0.8),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next_rounded, size: 32, color: SacredColors.parchment.withOpacity(0.5)),
                              onPressed: () => ref.read(audioPlayerControllerProvider).next(),
                            ),
                            IconButton(
                              icon: Icon(
                                loopMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                                size: 20,
                                color: loopMode != LoopMode.off ? SacredColors.parchment.withOpacity(0.7) : SacredColors.parchment.withOpacity(0.2),
                              ),
                              onPressed: () => ref.read(audioPlayerControllerProvider).toggleLoop(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Speed control
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.speed_rounded, size: 16, color: SacredColors.parchment.withOpacity(0.25)),
                            const SizedBox(width: 8),
                            ...[0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                              final isActive = speed == s;
                              return GestureDetector(
                                onTap: () => ref.read(audioPlayerControllerProvider).setSpeed(s),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? SacredColors.parchment.withOpacity(0.12) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isActive ? Border.all(color: SacredColors.parchment.withOpacity(0.2)) : null,
                                  ),
                                  child: Text(
                                    '${s}x',
                                    style: GoogleFonts.jost(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                      color: isActive ? SacredColors.parchmentLight.withOpacity(0.8) : SacredColors.parchment.withOpacity(0.25),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Playback controlled via YouTube player above',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 13, fontStyle: FontStyle.italic,
                              color: SacredColors.parchment.withOpacity(0.3),
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      // Recommendations section
                      recommendations.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (tracks) {
                          if (tracks.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              SacredDivider(margin: const EdgeInsets.symmetric(horizontal: 0)),
                              const SizedBox(height: 14),
                              Text('RECOMMENDED', style: SacredTextStyles.sectionLabel(fontSize: 8)),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tracks.length,
                                  itemBuilder: (context, index) {
                                    final track = tracks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        ref.read(audioPlayerControllerProvider).playTrack(track, tracks);
                                      },
                                      child: Container(
                                        width: 80,
                                        margin: const EdgeInsets.only(right: 12),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: SacredColors.parchment.withOpacity(0.15), width: 2),
                                                color: SacredColors.parchment.withOpacity(0.06),
                                              ),
                                              child: ClipOval(
                                                child: track.coverImageUrl != null
                                                    ? CachedNetworkImage(
                                                        imageUrl: track.coverImageUrl!,
                                                        fit: BoxFit.cover,
                                                        errorWidget: (_, __, ___) => Icon(Icons.music_note_rounded, color: SacredColors.parchment.withOpacity(0.3)),
                                                      )
                                                    : Icon(Icons.music_note_rounded, color: SacredColors.parchment.withOpacity(0.3)),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              track.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.jost(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w300,
                                                color: SacredColors.parchment.withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
<<<<<<< HEAD
                ),
=======
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40, color: Colors.blueGrey),
                    onPressed: () => ref.read(audioPlayerControllerProvider).next(),
                  ),
                  IconButton(
                    icon: Icon(
                      loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                      color: loopMode != LoopMode.off ? const Color(0xFF1565C0) : Colors.blueGrey,
                    ),
                    onPressed: () => ref.read(audioPlayerControllerProvider).toggleLoop(),
                  ),
                ],
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// ═══════════════════════════════════════════════════════════════
//  Rotating Disc Widget
// ═══════════════════════════════════════════════════════════════

class _RotatingDisc extends StatelessWidget {
  final AnimationController controller;
  final String? imageUrl;
  final double size;

  const _RotatingDisc({required this.controller, this.imageUrl, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: controller.value * 2 * pi,
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SacredColors.surface,
          border: Border.all(color: SacredColors.parchment.withOpacity(0.15), width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Grooves — decorative rings
            ...List.generate(4, (i) {
              final r = size / 2 - 20 - (i * 18);
              return Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SacredColors.parchment.withOpacity(0.04), width: 0.5),
                ),
              );
            }),
            // Cover image clipped as circle
            ClipOval(
              child: SizedBox(
                width: size * 0.55,
                height: size * 0.55,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _discCenter(),
                      )
                    : _discCenter(),
              ),
            ),
            // Center hole
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SacredColors.ink,
                border: Border.all(color: SacredColors.parchment.withOpacity(0.2), width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discCenter() {
    return Container(
<<<<<<< HEAD
      color: SacredColors.surface,
      child: Icon(Icons.music_note_rounded, size: 40, color: SacredColors.parchment.withOpacity(0.2)),
=======
      color: const Color(0xFFE8F5F9),
      child: const Icon(Icons.music_note, color: Color(0xFF1565C0), size: 100),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
    );
  }
}
