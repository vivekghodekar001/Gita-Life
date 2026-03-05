import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/assignment_service.dart';
import '../models/assignment.dart';

final assignmentServiceProvider =
    Provider<AssignmentService>((ref) => AssignmentService());

/// Stream of all assignments (used by both admin and students).
final assignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  return ref.watch(assignmentServiceProvider).streamAssignments();
});

/// Stream of submissions for a given assignment (admin view).
final submissionsForAssignmentProvider =
    StreamProvider.family<List<AssignmentSubmission>, String>(
        (ref, assignmentId) {
  return ref
      .watch(assignmentServiceProvider)
      .streamSubmissionsForAssignment(assignmentId);
});

/// Stream of a student's own submission for a given assignment.
final mySubmissionProvider = StreamProvider.family<AssignmentSubmission?,
    ({String assignmentId, String studentUid})>((ref, params) {
  return ref
      .watch(assignmentServiceProvider)
      .streamMySubmission(params.assignmentId, params.studentUid);
});
