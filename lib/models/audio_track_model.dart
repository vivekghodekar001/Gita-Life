import 'package:cloud_firestore/cloud_firestore.dart';

class AudioTrackModel {
  final String trackId;
  final String title;
  final String artist;
  final String category; // 'bhajan' | 'kirtan' | 'lecture_audio' | 'other'
  final String sourceType; // 'google_drive' | 'firebase_storage'
  final String? driveFileId;
  final String? storageRef;
  final String streamUrl;
  final int durationSeconds;
  final int fileSizeBytes;
  final String coverImageUrl;
  final bool isActive;
  final int playCount;
  final String addedBy;
  final DateTime createdAt;

  const AudioTrackModel({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.category,
    required this.sourceType,
    this.driveFileId,
    this.storageRef,
    required this.streamUrl,
    required this.durationSeconds,
    required this.fileSizeBytes,
    required this.coverImageUrl,
    required this.isActive,
    required this.playCount,
    required this.addedBy,
    required this.createdAt,
  });

  factory AudioTrackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AudioTrackModel(
      trackId: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      category: data['category'] ?? 'other',
      sourceType: data['sourceType'] ?? 'firebase_storage',
      driveFileId: data['driveFileId'],
      storageRef: data['storageRef'],
      streamUrl: data['streamUrl'] ?? '',
      durationSeconds: data['durationSeconds'] ?? 0,
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      coverImageUrl: data['coverImageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      playCount: data['playCount'] ?? 0,
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'category': category,
      'sourceType': sourceType,
      if (driveFileId != null) 'driveFileId': driveFileId,
      if (storageRef != null) 'storageRef': storageRef,
      'streamUrl': streamUrl,
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'playCount': playCount,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AudioTrackModel copyWith({
    String? trackId,
    String? title,
    String? artist,
    String? category,
    String? sourceType,
    String? driveFileId,
    String? storageRef,
    String? streamUrl,
    int? durationSeconds,
    int? fileSizeBytes,
    String? coverImageUrl,
    bool? isActive,
    int? playCount,
    String? addedBy,
    DateTime? createdAt,
  }) {
    return AudioTrackModel(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      driveFileId: driveFileId ?? this.driveFileId,
      storageRef: storageRef ?? this.storageRef,
      streamUrl: streamUrl ?? this.streamUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      playCount: playCount ?? this.playCount,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
