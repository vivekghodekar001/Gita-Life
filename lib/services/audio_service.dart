import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_track.dart';

class AudioService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[AudioService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  FirebaseStorage get _storage {
    _ensureFirebase();
    return FirebaseStorage.instanceFor(app: Firebase.app());
  }
  final Box<AudioTrackModel> _downloadsBox = Hive.box<AudioTrackModel>('downloads');
  final Dio _dio = Dio();

  Future<List<AudioTrackModel>> getAudioTracks([String? category]) async {
    Query query = _firestore.collection('audio_tracks').where('isActive', isEqualTo: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category.toLowerCase());
    }
    
    final snapshot = await query.get();
    
    final tracks = snapshot.docs.map((doc) => AudioTrackModel.fromFirestore(doc)).toList();
    tracks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tracks;
  }

  Future<String> buildStreamUrl(AudioTrackModel track) async {
    if (track.sourceType == 'google_drive' && track.driveFileId != null) {
      return 'https://drive.google.com/uc?export=download&id=\${track.driveFileId}';
    } else if (track.sourceType == 'firebase_storage' && track.storageRef != null) {
      return await _storage.ref(track.storageRef).getDownloadURL();
    } else if (track.sourceType == 'youtube') {
      return track.streamUrl ?? ''; // For YouTube, we store the ID or full URL in streamUrl
    } else if (track.streamUrl != null) {
      return track.streamUrl!;
    }
    throw Exception('Unknown source type or missing ID for track: \${track.title}');
  }

  Future<void> downloadTrack(AudioTrackModel track, Function(double) onProgress) async {
    if (_downloadsBox.containsKey(track.trackId)) return;

    try {
      final url = await buildStreamUrl(track);
      debugPrint('⏬ [DOWNLOAD]: Starting download for ${track.title}');
      debugPrint('⏬ [DOWNLOAD]: URL: $url');
      
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/audio_${track.trackId}.mp3';
      debugPrint('⏬ [DOWNLOAD]: Target path: $filePath');

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final downloadedTrack = track.copyWith(localFilePath: filePath);
      await _downloadsBox.put(track.trackId, downloadedTrack);
      debugPrint('✅ [DOWNLOAD]: Successfully downloaded ${track.title}');
    } catch (e, stack) {
      debugPrint('❌ [DOWNLOAD_ERROR]: Failed to download ${track.title}');
      debugPrint('❌ [DOWNLOAD_ERROR]: $e');
      debugPrint('❌ [DOWNLOAD_ERROR]: $stack');
      rethrow;
    }
  }

  List<AudioTrackModel> getDownloadedTracks() {
    return _downloadsBox.values.toList();
  }

  Future<void> deleteDownload(String trackId) async {
    final track = _downloadsBox.get(trackId);
    if (track != null && track.localFilePath != null) {
      final file = File(track.localFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
      await _downloadsBox.delete(trackId);
    }
  }

  Future<void> incrementPlayCount(String trackId) async {
    try {
      await _firestore.collection('audio_tracks').doc(trackId).update({
        'playCount': FieldValue.increment(1),
      });
    } catch(e) {
      // Ignored for permissions
    }
  }

  // Admin Methods
  Stream<List<AudioTrackModel>> watchAllAudioAdmin() {
    return _firestore.collection('audio_tracks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AudioTrackModel.fromFirestore(doc)).toList());
  }

  Future<void> addAudioTrack(AudioTrackModel track) async {
    await _firestore.collection('audio_tracks').doc(track.trackId).set(track.toFirestore());
  }

  Future<void> updateAudioTrack(String trackId, Map<String, dynamic> data) async {
    await _firestore.collection('audio_tracks').doc(trackId).update(data);
  }

  Future<void> toggleAudioActiveStatus(String trackId, bool isActive) async {
    await _firestore.collection('audio_tracks').doc(trackId).update({'isActive': isActive});
  }
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final adminAudioProvider = StreamProvider<List<AudioTrackModel>>((ref) {
  return ref.watch(audioServiceProvider).watchAllAudioAdmin();
});
