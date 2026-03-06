import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/assignment.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    Text('ASSIGNMENTS', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: assignmentsAsync.when(
                  data: (assignments) {
                    if (assignments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 48, color: SacredColors.parchment.withOpacity(0.15)),
                            const SizedBox(height: 14),
                            Text('No assignments yet.', style: SacredTextStyles.infoValue().copyWith(
                              color: SacredColors.parchment.withOpacity(0.3),
                            )),
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
                  loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
                  error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: SacredColors.parchment.withOpacity(0.5)))),
                ),
              ),
            ],
          ),
        ),
=======
      appBar: AppBar(
        title: const Text('Assignments'),
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
      ),
    );
  }
}

class _AssignmentStudentCard extends ConsumerWidget {
  final Assignment assignment;
  final dynamic userProfile;

  const _AssignmentStudentCard({required this.assignment, required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentUid = userProfile?.uid ?? '';
    final submissionAsync = studentUid.isNotEmpty
        ? ref.watch(mySubmissionProvider(
            (assignmentId: assignment.assignmentId, studentUid: studentUid)))
        : null;

    final isOverdue = assignment.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SacredDecorations.glassCard(radius: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SacredColors.parchment.withOpacity(0.08),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                      ),
                      child: Icon(Icons.assignment_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
=======
                const CircleAvatar(
                  backgroundColor: Color(0x1A1565C0),
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                        children: [
                          Text(
                            assignment.title,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 16, fontWeight: FontWeight.w600,
                              color: SacredColors.parchmentLight.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 11,
                                  color: isOverdue ? SacredColors.ember.withOpacity(0.7) : SacredColors.parchment.withOpacity(0.3)),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
                                style: GoogleFonts.jost(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                  color: isOverdue ? SacredColors.ember.withOpacity(0.7) : SacredColors.parchment.withOpacity(0.3),
                                ),
                              ),
                              if (isOverdue) ...[
                                const SizedBox(width: 4),
                                Text('(Overdue)',
                                    style: GoogleFonts.jost(fontSize: 10, color: SacredColors.ember.withOpacity(0.7))),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    assignment.description,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      color: SacredColors.parchment.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (submissionAsync != null)
                  submissionAsync.when(
                    data: (submission) => _buildSubmissionStatus(context, ref, submission),
                    loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
                    error: (e, _) => Text('Error: $e', style: TextStyle(color: SacredColors.ember.withOpacity(0.6))),
                  )
                else
                  Text('Log in to submit assignments.',
                      style: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.3))),
              ],
            ),
          ),
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
<<<<<<< HEAD
        child: GestureDetector(
          onTap: userProfile != null ? () => _submitAssignment(context, ref) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: SacredColors.parchment.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SacredColors.parchment.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'MARK AS DONE',
                  style: GoogleFonts.jost(
                    fontSize: 11, fontWeight: FontWeight.w300, letterSpacing: 2,
                    color: SacredColors.parchment.withOpacity(0.6),
                  ),
                ),
              ],
            ),
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
          ),
        ),
      );
    }

    // Show progress only if admin has completed the review
    if (submission.status == 'completed') {
      return Row(
        children: [
          Icon(Icons.verified_rounded, size: 18, color: const Color(0xFF4CAF50).withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            'Completed — Verified by admin',
            style: GoogleFonts.jost(
              fontSize: 12, fontWeight: FontWeight.w300,
              color: const Color(0xFF4CAF50).withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    // Pending review
    return Row(
      children: [
        Icon(Icons.hourglass_top_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text(
          'Submitted — Awaiting admin review',
          style: GoogleFonts.jost(
            fontSize: 12, fontWeight: FontWeight.w300,
            color: SacredColors.parchment.withOpacity(0.4),
          ),
        ),
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
          SnackBar(
            content: const Text('Assignment marked as done! Admin will review.'),
            backgroundColor: SacredColors.surface,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: SacredColors.surface),
        );
      }
    }
  }
}
