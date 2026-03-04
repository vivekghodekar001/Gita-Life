import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track.dart';
import '../services/audio_service.dart' as app_audio;
import '../main.dart'; // provides audioHandler

final audioServiceProvider = Provider<app_audio.AudioService>((ref) {
  return app_audio.AudioService();
});

final audioTracksProvider = FutureProvider.family<List<AudioTrackModel>, String?>((ref, category) {
  return ref.read(audioServiceProvider).getAudioTracks(category);
});

final downloadedTracksProvider = StateNotifierProvider<DownloadNotifier, List<AudioTrackModel>>((ref) {
  final service = ref.read(audioServiceProvider);
  return DownloadNotifier(service);
});

class DownloadNotifier extends StateNotifier<List<AudioTrackModel>> {
  final app_audio.AudioService _service;

  DownloadNotifier(this._service) : super(_service.getDownloadedTracks());

  void refresh() {
    state = _service.getDownloadedTracks();
  }

  Future<void> downloadTrack(AudioTrackModel track) async {
    await _service.downloadTrack(track, (progress) {
       // Optional: Push progress stream natively via dedicated logic provider
    });
    refresh();
  }

  Future<void> deleteDownload(String trackId) async {
    await _service.deleteDownload(trackId);
    refresh();
  }
}

final activeTrackProvider = StateProvider<AudioTrackModel?>((ref) => null);
final currentPlaylistProvider = StateProvider<List<AudioTrackModel>>((ref) => []);

final audioPlayerControllerProvider = Provider<AudioPlayerController>((ref) {
  return AudioPlayerController(ref);
});

class AudioPlayerController {
  final Ref ref;
  
  AudioPlayerController(this.ref) {
    audioHandler?.player.currentIndexStream.listen((index) {
       if (index != null) {
         final tracks = ref.read(currentPlaylistProvider);
         if (index >= 0 && index < tracks.length) {
            final track = tracks[index];
            if (ref.read(activeTrackProvider)?.trackId != track.trackId) {
               ref.read(activeTrackProvider.notifier).state = track;
               ref.read(audioServiceProvider).incrementPlayCount(track.trackId);
            }
         }
       }
    });
  }

  Future<void> playTrack(AudioTrackModel track, List<AudioTrackModel> playlistContext) async {
    ref.read(currentPlaylistProvider.notifier).state = playlistContext;
    ref.read(activeTrackProvider.notifier).state = track;

    final service = ref.read(audioServiceProvider);
    
    final audioSources = <AudioSource>[];
    int initialIndex = 0;
    
    for (int i = 0; i < playlistContext.length; i++) {
       final t = playlistContext[i];
       if (t.trackId == track.trackId) initialIndex = i;
       
       if (t.localFilePath != null) {
          audioSources.add(AudioSource.file(t.localFilePath!, tag: t.trackId));
       } else {
          final url = await service.buildStreamUrl(t);
          audioSources.add(AudioSource.uri(Uri.parse(url), tag: t.trackId));
       }
    }
    
    final playlist = ConcatenatingAudioSource(children: audioSources);
    await audioHandler?.player.setAudioSource(playlist, initialIndex: initialIndex);
    audioHandler?.play();
  }

  void togglePlay() {
    if (audioHandler?.player.playing == true) {
      audioHandler?.pause();
    } else {
      audioHandler?.play();
    }
  }

  void stop() => audioHandler?.stop();
  Future<void> next() => audioHandler?.skipToNext() ?? Future.value();
  Future<void> previous() => audioHandler?.skipToPrevious() ?? Future.value();
  void seek(Duration pos) => audioHandler?.seek(pos);
  void setSpeed(double speed) => audioHandler?.setSpeed(speed);
  void toggleShuffle() {
    final player = audioHandler?.player;
    if (player != null) {
      player.setShuffleModeEnabled(!player.shuffleModeEnabled);
    }
  }
  void toggleLoop() {
    final player = audioHandler?.player;
    if (player == null) return;
    final mode = player.loopMode;
    if (mode == LoopMode.off) player.setLoopMode(LoopMode.one);
    else if (mode == LoopMode.one) player.setLoopMode(LoopMode.all);
    else player.setLoopMode(LoopMode.off);
  }
}

final playbackStateProvider = StreamProvider<ProcessingState>((ref) =>
    audioHandler?.player.processingStateStream ?? const Stream.empty());
final isPlayingProvider = StreamProvider<bool>((ref) =>
    audioHandler?.player.playingStream ?? const Stream.empty());
final positionProvider = StreamProvider<Duration>((ref) =>
    audioHandler?.player.positionStream ?? const Stream.empty());
final bufferedPositionProvider = StreamProvider<Duration>((ref) =>
    audioHandler?.player.bufferedPositionStream ?? const Stream.empty());
final durationProvider = StreamProvider<Duration?>((ref) =>
    audioHandler?.player.durationStream ?? const Stream.empty());
final speedProvider = StreamProvider<double>((ref) =>
    audioHandler?.player.speedStream ?? const Stream.empty());
final loopModeProvider = StreamProvider<LoopMode>((ref) =>
    audioHandler?.player.loopModeStream ?? const Stream.empty());
final shuffleModeProvider = StreamProvider<bool>((ref) =>
    audioHandler?.player.shuffleModeEnabledStream ?? const Stream.empty());
