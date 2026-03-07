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
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.6)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    Text('ASSIGNMENTS', style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(color: SacredColors.parchment.withOpacity(0.6))),
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
                            Icon(Icons.assignment_outlined, size: 48, color: SacredColors.parchment.withOpacity(0.25)),
                            const SizedBox(height: 14),
                            Text('No assignments yet.', style: GoogleFonts.cormorantGaramond(
                              fontSize: 16, color: SacredColors.parchment.withOpacity(0.45),
                            )),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) => _ParchmentAssignmentCard(
                        assignment: assignments[index],
                        userProfile: userProfile,
                      ),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: const Color(0xFF8B4513).withOpacity(0.6))),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 36, color: SacredColors.parchment.withOpacity(0.25)),
                        const SizedBox(height: 12),
                        Text(
                          err.toString().contains('permission-denied')
                              ? 'Assignments will appear once your account is approved.'
                              : 'Could not load assignments. Please try again.',
                          style: TextStyle(color: SacredColors.parchment.withOpacity(0.45), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParchmentAssignmentCard extends ConsumerWidget {
  final Assignment assignment;
  final dynamic userProfile;

  const _ParchmentAssignmentCard({required this.assignment, required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentUid = userProfile?.uid ?? '';
    final submissionAsync = studentUid.isNotEmpty
        ? ref.watch(mySubmissionProvider(
            (assignmentId: assignment.assignmentId, studentUid: studentUid)))
        : null;

    final isOverdue = assignment.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4), Color(0xFFE4D4B0)],
        ),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A2C0A).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF8B4513).withOpacity(0.15), const Color(0xFFC8722A).withOpacity(0.1)],
                    ),
                    border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.25)),
                  ),
                  child: Icon(Icons.assignment_rounded, size: 18, color: const Color(0xFF8B4513).withOpacity(0.7)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 17, fontWeight: FontWeight.w600,
                          color: const Color(0xFF3A2010),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 11,
                              color: isOverdue ? SacredColors.ember : const Color(0xFF8B6914).withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
                            style: GoogleFonts.jost(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: isOverdue ? SacredColors.ember : const Color(0xFF5C4033).withOpacity(0.6),
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 4),
                            Text('(Overdue)',
                                style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w600, color: SacredColors.ember)),
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
                  color: const Color(0xFF5C4033).withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Separator
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, const Color(0xFF8B6914).withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (submissionAsync != null)
              submissionAsync.when(
                data: (submission) => _buildSubmissionStatus(context, ref, submission),
                loading: () => Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: const Color(0xFF8B4513).withOpacity(0.5), strokeWidth: 1.5))),
                error: (e, _) => Text(
                    e.toString().contains('permission-denied') ? 'Pending approval.' : 'Could not load.',
                    style: TextStyle(color: SacredColors.ember.withOpacity(0.7), fontSize: 12)),
              )
            else
              Text('Log in to submit assignments.',
                  style: GoogleFonts.jost(fontSize: 12, color: const Color(0xFF5C4033).withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionStatus(BuildContext context, WidgetRef ref,
      AssignmentSubmission? submission) {
    if (submission == null) {
      return SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: userProfile != null ? () => _submitAssignment(context, ref) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8B4513).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFFF5E8D0)),
                const SizedBox(width: 8),
                Text(
                  'MARK AS DONE',
                  style: GoogleFonts.jost(
                    fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 2,
                    color: const Color(0xFFF5E8D0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (submission.status == 'completed') {
      return Row(
        children: [
          const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF4A8B4A)),
          const SizedBox(width: 8),
          Text(
            'Completed — Verified by admin',
            style: GoogleFonts.jost(
              fontSize: 12, fontWeight: FontWeight.w400,
              color: const Color(0xFF4A8B4A),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.hourglass_top_rounded, size: 18, color: const Color(0xFF8B6914).withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          'Submitted — Awaiting admin review',
          style: GoogleFonts.jost(
            fontSize: 12, fontWeight: FontWeight.w400,
            color: const Color(0xFF8B6914).withOpacity(0.6),
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
          const SnackBar(content: Text('Assignment marked as done! Admin will review.')),
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
