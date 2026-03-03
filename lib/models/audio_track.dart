import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'audio_track.g.dart';

@HiveType(typeId: 1)
class AudioTrackModel extends HiveObject {
  @HiveField(0)
  final String trackId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String category; // bhajan, kirtan, lecture_audio, other

  @HiveField(4)
  final String sourceType; // google_drive, firebase_storage, direct_url

  @HiveField(5)
  final String? driveFileId;

  @HiveField(6)
  final String? storageRef;

  @HiveField(7)
  final String? streamUrl; // Used for direct_url or when URL is calculated dynamically

  @HiveField(8)
  final int durationSeconds;

  @HiveField(9)
  final int fileSizeBytes;

  @HiveField(10)
  final String? coverImageUrl;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final int playCount;

  @HiveField(13)
  final String addedBy;

  @HiveField(14)
  final String createdAt;

  // For downloaded tracks ONLY
  @HiveField(15)
  String? localFilePath;

  AudioTrackModel({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.category,
    required this.sourceType,
    this.driveFileId,
    this.storageRef,
    this.streamUrl,
    required this.durationSeconds,
    required this.fileSizeBytes,
    this.coverImageUrl,
    required this.isActive,
    required this.playCount,
    required this.addedBy,
    required this.createdAt,
    this.localFilePath,
  });

  factory AudioTrackModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return AudioTrackModel(
      trackId: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? 'Unknown',
      category: data['category'] ?? 'other',
      sourceType: data['sourceType'] ?? 'direct_url',
      driveFileId: data['driveFileId'],
      storageRef: data['storageRef'],
      streamUrl: data['streamUrl'],
      durationSeconds: data['durationSeconds'] ?? 0,
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      coverImageUrl: data['coverImageUrl'],
      isActive: data['isActive'] ?? true,
      playCount: data['playCount'] ?? 0,
      addedBy: data['addedBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'category': category,
      'sourceType': sourceType,
      'driveFileId': driveFileId,
      'storageRef': storageRef,
      'streamUrl': streamUrl,
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'playCount': playCount,
      'addedBy': addedBy,
      'createdAt': createdAt,
    };
  }

  AudioTrackModel copyWith({
    String? localFilePath,
  }) {
    return AudioTrackModel(
      trackId: trackId,
      title: title,
      artist: artist,
      category: category,
      sourceType: sourceType,
      driveFileId: driveFileId,
      storageRef: storageRef,
      streamUrl: streamUrl,
      durationSeconds: durationSeconds,
      fileSizeBytes: fileSizeBytes,
      coverImageUrl: coverImageUrl,
      isActive: isActive,
      playCount: playCount,
      addedBy: addedBy,
      createdAt: createdAt,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }
}
