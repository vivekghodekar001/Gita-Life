import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

// Provide a state for the current filter
final studentFilterProvider = StateProvider<String>((ref) => 'all');

class ManageStudentsScreen extends ConsumerWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(studentFilterProvider);
    final usersAsync = ref.watch(usersProvider(currentFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () async {
              final users = usersAsync.valueOrNull;
              if (users != null && users.isNotEmpty) {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating CSV...')),
                  );
                  await ref.read(userActionsProvider).exportUsersCsv(users);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error exporting CSV: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No students to export')),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(
        children: [
          _buildFilterChips(ref, currentFilter),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildStudentCard(context, ref, user);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE65100))),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, String currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(ref, currentFilter, 'All', 'all'),
          const SizedBox(width: 8),
          _buildChip(ref, currentFilter, 'Pending', 'pending'),
          const SizedBox(width: 8),
          _buildChip(ref, currentFilter, 'Active', 'active'),
          const SizedBox(width: 8),
          _buildChip(ref, currentFilter, 'Suspended', 'suspended'),
        ],
      ),
    );
  }

  Widget _buildChip(WidgetRef ref, String currentFilter, String label, String value) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(studentFilterProvider.notifier).state = value;
      },
      selectedColor: const Color(0xFFE65100).withOpacity(0.2),
      checkmarkColor: const Color(0xFFE65100),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFE65100) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, WidgetRef ref, UserModel user) {
    Color statusColor;
    switch (user.status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'suspended':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE65100).withOpacity(0.1),
          backgroundImage: user.profilePhotoUrl.isNotEmpty ? NetworkImage(user.profilePhotoUrl) : null,
          child: user.profilePhotoUrl.isEmpty
              ? Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Roll: ${user.rollNumber}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Text(
            user.status.toUpperCase(),
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoRow('Email', user.email),
                const SizedBox(height: 8),
                _buildInfoRow('Phone', user.phoneNumber),
                const SizedBox(height: 8),
                _buildInfoRow('Role', user.role),
                const SizedBox(height: 8),
                _buildInfoRow('Enrolled', DateFormat('MMM d, yyyy').format(user.enrollmentDate)),
                if (user.address != null && user.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Address', user.address!),
                ],
                if (user.dateOfBirth != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Date of Birth', DateFormat('MMM d, yyyy').format(user.dateOfBirth!)),
                ],
                if (user.collegeBranch != null && user.collegeBranch!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Branch', user.collegeBranch!),
                ],
                if (user.year != null && user.year!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Year', user.year!),
                ],
                if (user.interests != null && user.interests!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Interests', user.interests!.join(', ')),
                ],
                if (user.skills != null && user.skills!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Skills', user.skills!.join(', ')),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (user.status == 'pending' || user.status == 'suspended')
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(context, ref, user.uid, 'active'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    if (user.status == 'active')
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(context, ref, user.uid, 'suspended'),
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Suspend'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String uid, String newStatus) async {
    try {
      await ref.read(userActionsProvider).updateUserStatus(uid, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }
}

