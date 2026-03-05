import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String assignmentId;
  final String title;
  final String description;
  final String createdBy;
  final DateTime dueDate;
  final DateTime createdAt;

  const Assignment({
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.dueDate,
    required this.createdAt,
  });

  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return Assignment(
      assignmentId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      dueDate: parseDate(data['dueDate']),
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Tracks whether a specific student has submitted/completed an assignment.
class AssignmentSubmission {
  final String submissionId;
  final String assignmentId;
  final String studentUid;
  final String studentName;
  final String rollNumber;
  /// 'pending' | 'submitted' | 'completed'
  final String status;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  const AssignmentSubmission({
    required this.submissionId,
    required this.assignmentId,
    required this.studentUid,
    required this.studentName,
    required this.rollNumber,
    required this.status,
    this.submittedAt,
    this.completedAt,
  });

  factory AssignmentSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return AssignmentSubmission(
      submissionId: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      status: data['status'] ?? 'pending',
      submittedAt: parseDate(data['submittedAt']),
      completedAt: parseDate(data['completedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentUid': studentUid,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'status': status,
      if (submittedAt != null) 'submittedAt': Timestamp.fromDate(submittedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }
}
