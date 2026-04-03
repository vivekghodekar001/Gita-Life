import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDevoteeAssignmentsScreen extends ConsumerStatefulWidget {
  const ManageDevoteeAssignmentsScreen({super.key});

  @override
  ConsumerState<ManageDevoteeAssignmentsScreen> createState() => _ManageDevoteeAssignmentsScreenState();
}

class _ManageDevoteeAssignmentsScreenState extends ConsumerState<ManageDevoteeAssignmentsScreen> {
  String? _selectedCounselorUid;
  bool _isSaving = false;

  Future<void> _updateAssignment(UserModel student, String? counselorUid) async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(student.uid).update({
        'counselorUid': counselorUid,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assignments'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Counselor Selection Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Counselor',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    counselorsAsync.when(
                      data: (counselors) => DropdownButtonFormField<String>(
                        value: _selectedCounselorUid,
                        hint: const Text('All Counselors'),
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (val) => setState(() => _selectedCounselorUid = val),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Counselors / Unassigned'),
                          ),
                          ...counselors.map((c) => DropdownMenuItem(
                                value: c.uid,
                                child: Text(c.fullName),
                              )),
                        ],
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),

            // Devotees List
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  final students = users.where((u) => u.role != 'admin' && u.role != 'counselor').toList();
                  final filteredStudents = _selectedCounselorUid == null
                      ? students
                      : students.where((u) => u.counselorUid == _selectedCounselorUid).toList();

                  if (filteredStudents.isEmpty) {
                    return const Center(
                      child: Text('No students found matching the criteria'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: ${student.phoneNumber}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.counselorUid == null ? 'Unassigned' : 'Assigned',
                                    style: TextStyle(
                                      color: student.counselorUid == null ? Colors.orange : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: counselorsAsync.when(
                            data: (counselors) => PopupMenuButton<String?>(
                              icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                              tooltip: 'Assign to Counselor',
                              onSelected: (cid) => _updateAssignment(student, cid),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: null,
                                  child: Text('Unassign Counselor'),
                                ),
                                const PopupMenuDivider(),
                                ...counselors.map((c) => PopupMenuItem(
                                      value: c.uid,
                                      child: Text('Assign to: ${c.fullName}'),
                                    )),
                              ],
                            ),
                            loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                            error: (_, __) => const Icon(Icons.error_outline),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
