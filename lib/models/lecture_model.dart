import 'package:cloud_firestore/cloud_firestore.dart';

class LectureModel {
  final String lectureId;
  final String title;
  final String description;
  final String youtubeVideoId;
  final String thumbnailUrl;
  final String topic;
  final int durationMinutes;
  final int viewCount;
  final bool isActive;
  final String addedBy;
  final DateTime createdAt;

  const LectureModel({
    required this.lectureId,
    required this.title,
    required this.description,
    required this.youtubeVideoId,
    required this.thumbnailUrl,
    required this.topic,
    required this.durationMinutes,
    required this.viewCount,
    required this.isActive,
    required this.addedBy,
    required this.createdAt,
  });

  factory LectureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LectureModel(
      lectureId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeVideoId: data['youtubeVideoId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      topic: data['topic'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'youtubeVideoId': youtubeVideoId,
      'thumbnailUrl': thumbnailUrl,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'viewCount': viewCount,
      'isActive': isActive,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  LectureModel copyWith({
    String? lectureId,
    String? title,
    String? description,
    String? youtubeVideoId,
    String? thumbnailUrl,
    String? topic,
    int? durationMinutes,
    int? viewCount,
    bool? isActive,
    String? addedBy,
    DateTime? createdAt,
  }) {
    return LectureModel(
      lectureId: lectureId ?? this.lectureId,
      title: title ?? this.title,
      description: description ?? this.description,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      topic: topic ?? this.topic,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      viewCount: viewCount ?? this.viewCount,
      isActive: isActive ?? this.isActive,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
