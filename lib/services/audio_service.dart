import 'package:path_provider/path_provider.dart';
import '../models/audio_track_model.dart';

class AudioService {
  Future<List<AudioTrackModel>> getAudioTracks({String? category}) async {
    // TODO: Fetch audio tracks from Firestore, optionally filtered by category
    throw UnimplementedError();
  }

  Future<String> buildStreamUrl(AudioTrackModel track) async {
    // TODO: Build streaming URL based on sourceType (google_drive or firebase_storage)
    throw UnimplementedError();
  }

  Future<void> downloadTrack(AudioTrackModel track) async {
    // TODO: Download audio file to local storage, save metadata to Hive
    throw UnimplementedError();
  }

  Future<List<AudioTrackModel>> getDownloadedTracks() async {
    // TODO: Return list of locally downloaded tracks from Hive
    throw UnimplementedError();
  }

  Future<void> deleteDownload(String trackId) async {
    // TODO: Delete downloaded audio file and remove from Hive
    throw UnimplementedError();
  }

  Future<void> incrementPlayCount(String trackId) async {
    // TODO: Increment playCount field in Firestore for given trackId
    throw UnimplementedError();
  }
}
