import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String recordId;
  final String sessionId;
  final String studentUid;
  final String studentName;
  final String rollNumber;
  final String status; // 'present' | 'absent' | 'late'
  final String markedBy;
  final DateTime markedAt;

  const AttendanceRecord({
    required this.recordId,
    required this.sessionId,
    required this.studentUid,
    required this.studentName,
    required this.rollNumber,
    required this.status,
    required this.markedBy,
    required this.markedAt,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      recordId: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      status: data['status'] ?? 'absent',
      markedBy: data['markedBy'] ?? '',
      markedAt: (data['markedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentUid': studentUid,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'status': status,
      'markedBy': markedBy,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }

  AttendanceRecord copyWith({
    String? recordId,
    String? sessionId,
    String? studentUid,
    String? studentName,
    String? rollNumber,
    String? status,
    String? markedBy,
    DateTime? markedAt,
  }) {
    return AttendanceRecord(
      recordId: recordId ?? this.recordId,
      sessionId: sessionId ?? this.sessionId,
      studentUid: studentUid ?? this.studentUid,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      status: status ?? this.status,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
    );
  }
}
