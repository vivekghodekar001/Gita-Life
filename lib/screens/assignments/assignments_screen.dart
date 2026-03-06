import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/assignment.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: const Color(0xFFE8F5F9),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8F5F9),
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No assignments yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) => _AssignmentStudentCard(
              assignment: assignments[index],
              userProfile: userProfile,
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _AssignmentStudentCard extends ConsumerWidget {
  final Assignment assignment;
  final dynamic userProfile;

  const _AssignmentStudentCard(
      {required this.assignment, required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentUid = userProfile?.uid ?? '';
    final submissionAsync = studentUid.isNotEmpty
        ? ref.watch(mySubmissionProvider(
            (assignmentId: assignment.assignmentId, studentUid: studentUid)))
        : null;

    final isOverdue = assignment.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0x1AE65100),
                  child: Icon(Icons.assignment, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12,
                              color: isOverdue ? Colors.red : Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    isOverdue ? Colors.red : Colors.grey[600]),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 4),
                            const Text('(Overdue)',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.red)),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (assignment.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(assignment.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
            const SizedBox(height: 16),
            if (submissionAsync != null)
              submissionAsync.when(
                data: (submission) =>
                    _buildSubmissionStatus(context, ref, submission),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              )
            else
              const Text('Log in to submit assignments.',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionStatus(BuildContext context, WidgetRef ref,
      AssignmentSubmission? submission) {
    if (submission == null) {
      // Not yet submitted
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: userProfile != null
              ? () => _submitAssignment(context, ref)
              : null,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Mark as Done (Submitted Offline)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (submission.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = 'Completed by admin';
        break;
      case 'submitted':
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_top;
        statusText = 'Submitted — awaiting admin review';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = submission.status;
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor),
        const SizedBox(width: 8),
        Text(statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _submitAssignment(BuildContext context, WidgetRef ref) async {
    if (userProfile == null) return;
    try {
      await ref.read(assignmentServiceProvider).submitAssignment(
            assignmentId: assignment.assignmentId,
            studentUid: userProfile!.uid,
            studentName: userProfile!.fullName,
            rollNumber: userProfile!.rollNumber,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Assignment marked as done! Admin will review.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }
}
