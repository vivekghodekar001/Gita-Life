import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/assignment.dart';

class AssignmentService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception(
          '[AssignmentService] Firebase not initialized.');
    }
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  FirebaseAuth get _auth {
    _ensureFirebase();
    return FirebaseAuth.instanceFor(app: Firebase.app());
  }

  // ── Admin: create assignment ────────────────────────────────────────────────

  Future<Assignment> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final docRef = _firestore.collection('assignments').doc();
    final assignment = Assignment(
      assignmentId: docRef.id,
      title: title,
      description: description,
      createdBy: _auth.currentUser?.uid ?? 'unknown',
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    await docRef.set(assignment.toFirestore());
    return assignment;
  }

  // ── Admin: delete assignment ────────────────────────────────────────────────

  Future<void> deleteAssignment(String assignmentId) async {
    await _firestore.collection('assignments').doc(assignmentId).delete();
  }

  // ── Admin: mark student submission as complete ──────────────────────────────

  Future<void> markSubmissionComplete(String submissionId) async {
    await _firestore
        .collection('assignment_submissions')
        .doc(submissionId)
        .update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Admin: get all submissions for an assignment ────────────────────────────

  Stream<List<AssignmentSubmission>> streamSubmissionsForAssignment(
      String assignmentId) {
    return _firestore
        .collection('assignment_submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AssignmentSubmission.fromFirestore(doc))
            .toList());
  }

  // ── Shared: list all assignments ────────────────────────────────────────────

  Stream<List<Assignment>> streamAssignments() {
    return _firestore
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Assignment.fromFirestore(doc)).toList());
  }

  // ── Student: get own submission for an assignment ───────────────────────────

  Stream<AssignmentSubmission?> streamMySubmission(
      String assignmentId, String studentUid) {
    return _firestore
        .collection('assignment_submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : AssignmentSubmission.fromFirestore(snap.docs.first));
  }

  // ── Student: mark assignment as done (offline submission) ──────────────────

  Future<void> submitAssignment({
    required String assignmentId,
    required String studentUid,
    required String studentName,
    required String rollNumber,
  }) async {
    final submissionId = '${assignmentId}_$studentUid';
    final docRef =
        _firestore.collection('assignment_submissions').doc(submissionId);

    await docRef.set({
      'assignmentId': assignmentId,
      'studentUid': studentUid,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'status': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
