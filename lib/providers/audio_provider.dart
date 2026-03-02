import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../models/audio_track_model.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final audioTracksProvider = FutureProvider.family<List<AudioTrackModel>, String?>((ref, category) {
  return ref.watch(audioServiceProvider).getAudioTracks(category: category);
});

final downloadedTracksProvider = FutureProvider<List<AudioTrackModel>>((ref) {
  return ref.watch(audioServiceProvider).getDownloadedTracks();
});
