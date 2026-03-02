import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSession {
  final String sessionId;
  final String title;
  final String topic;
  final DateTime lectureDate;
  final String createdBy;
  final bool isLocked;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final DateTime createdAt;

  const AttendanceSession({
    required this.sessionId,
    required this.title,
    required this.topic,
    required this.lectureDate,
    required this.createdBy,
    required this.isLocked,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.createdAt,
  });

  factory AttendanceSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceSession(
      sessionId: doc.id,
      title: data['title'] ?? '',
      topic: data['topic'] ?? '',
      lectureDate: (data['lectureDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isLocked: data['isLocked'] ?? false,
      totalStudents: data['totalStudents'] ?? 0,
      presentCount: data['presentCount'] ?? 0,
      absentCount: data['absentCount'] ?? 0,
      lateCount: data['lateCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'topic': topic,
      'lectureDate': Timestamp.fromDate(lectureDate),
      'createdBy': createdBy,
      'isLocked': isLocked,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'lateCount': lateCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AttendanceSession copyWith({
    String? sessionId,
    String? title,
    String? topic,
    DateTime? lectureDate,
    String? createdBy,
    bool? isLocked,
    int? totalStudents,
    int? presentCount,
    int? absentCount,
    int? lateCount,
    DateTime? createdAt,
  }) {
    return AttendanceSession(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      lectureDate: lectureDate ?? this.lectureDate,
      createdBy: createdBy ?? this.createdBy,
      isLocked: isLocked ?? this.isLocked,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
