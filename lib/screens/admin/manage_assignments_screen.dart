import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/assignment_provider.dart';
import '../../models/assignment.dart';
import '../../app/sacred_theme.dart';

class ManageAssignmentsScreen extends ConsumerWidget {
  const ManageAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assignments'),
        elevation: 0,
      ),
      backgroundColor: SacredColors.ink,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: const Color(0xFF8B4513),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Assignment', style: TextStyle(color: Colors.white)),
      ),
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
                  SizedBox(height: 8),
                  Text('Tap "+ New Assignment" to create one.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: assignments.length,
            itemBuilder: (context, index) =>
                _AssignmentAdminCard(assignment: assignments[index]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM d, yyyy').format(dueDate)),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a title.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await ref.read(assignmentServiceProvider).createAssignment(
                        title: title,
                        description: descController.text.trim(),
                        dueDate: dueDate,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment created.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create: $e')),
                    );
                  }
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentAdminCard extends ConsumerWidget {
  final Assignment assignment;
  const _AssignmentAdminCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync =
        ref.watch(submissionsForAssignmentProvider(assignment.assignmentId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1A1565C0),
          child: Icon(Icons.assignment, color: Color(0xFF1565C0)),
        ),
        title: Text(assignment.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (assignment.description.isNotEmpty)
                  Text(assignment.description,
                      style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                const Text('Submissions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                submissionsAsync.when(
                  data: (submissions) {
                    if (submissions.isEmpty) {
                      return const Text('No submissions yet.',
                          style: TextStyle(color: Colors.grey));
                    }
                    return Column(
                      children: submissions.map((sub) {
                        Color statusColor;
                        switch (sub.status) {
                          case 'completed':
                            statusColor = Colors.green;
                            break;
                          case 'submitted':
                            statusColor = Colors.blue;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(sub.studentName),
                          subtitle: Text('Roll: ${sub.rollNumber}'),
                          trailing: sub.status == 'submitted'
                              ? ElevatedButton(
                                  onPressed: () => _markComplete(
                                      context, ref, sub.submissionId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                  ),
                                  child: const Text('Mark Complete'),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    sub.status.toUpperCase(),
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Text('Error loading submissions: $e'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        _deleteAssignment(context, ref, assignment.assignmentId),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markComplete(
      BuildContext context, WidgetRef ref, String submissionId) async {
    try {
      await ref
          .read(assignmentServiceProvider)
          .markSubmissionComplete(submissionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as complete.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteAssignment(
      BuildContext context, WidgetRef ref, String assignmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment'),
        content:
            const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(assignmentServiceProvider)
            .deleteAssignment(assignmentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment deleted.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }
}
