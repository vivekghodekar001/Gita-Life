import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';
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
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    Text('MANAGE STUDENTS', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.download_rounded, size: 20, color: SacredColors.parchment.withOpacity(0.4)),
                      tooltip: 'Export CSV',
                      onPressed: () async {
                        final users = usersAsync.valueOrNull;
                        if (users != null && users.isNotEmpty) {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('Generating CSV...'), backgroundColor: SacredColors.surface),
                            );
                            await ref.read(userActionsProvider).exportUsersCsv(users);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: SacredColors.surface),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Filter chips — sacred dark
              _buildFilterChips(ref, currentFilter),
              const SizedBox(height: 8),
              Expanded(
                child: usersAsync.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return Center(child: Text('No students found.', style: SacredTextStyles.infoValue().copyWith(
                        color: SacredColors.parchment.withOpacity(0.3),
                      )));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) => _buildStudentCard(context, ref, users[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
                  error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: SacredColors.parchment.withOpacity(0.5)))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, String currentFilter) {
    final filters = [
      ('All', 'all'),
      ('Pending', 'pending'),
      ('Active', 'active'),
      ('Suspended', 'suspended'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final isSelected = currentFilter == f.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ref.read(studentFilterProvider.notifier).state = f.$2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SacredColors.parchment.withOpacity(0.15)
                      : SacredColors.parchment.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? SacredColors.parchment.withOpacity(0.4)
                        : SacredColors.parchment.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  f.$1.toUpperCase(),
                  style: GoogleFonts.jost(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                    color: isSelected
                        ? SacredColors.parchmentLight.withOpacity(0.9)
                        : SacredColors.parchment.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, WidgetRef ref, UserModel user) {
    Color statusColor;
    switch (user.status) {
      case 'active':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'pending':
        statusColor = SacredColors.parchment;
        break;
      case 'suspended':
        statusColor = SacredColors.ember;
        break;
      default:
        statusColor = SacredColors.ash;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: SacredDecorations.glassCard(radius: 12),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: SacredColors.parchment.withOpacity(0.4),
            collapsedIconColor: SacredColors.parchment.withOpacity(0.2),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SacredColors.parchment.withOpacity(0.06),
              border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
              image: user.profilePhotoUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(user.profilePhotoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: user.profilePhotoUrl.isEmpty
                ? Center(
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: GoogleFonts.cormorantSc(fontSize: 16, color: SacredColors.parchment.withOpacity(0.5)),
                    ),
                  )
                : null,
          ),
          title: Text(
            user.fullName,
            style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.w600,
              color: SacredColors.parchmentLight.withOpacity(0.8)),
          ),
          subtitle: Text(
            'Roll: ${user.rollNumber}',
            style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w300,
              color: SacredColors.parchment.withOpacity(0.3)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              user.status.toUpperCase(),
              style: GoogleFonts.jost(fontSize: 8, fontWeight: FontWeight.w300, letterSpacing: 1, color: statusColor.withOpacity(0.8)),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoRow('Email', user.email),
                  const SizedBox(height: 6),
                  _buildInfoRow('Phone', user.phoneNumber),
                  const SizedBox(height: 6),
                  _buildInfoRow('Role', user.role),
                  const SizedBox(height: 6),
                  _buildInfoRow('Enrolled', DateFormat('MMM d, yyyy').format(user.enrollmentDate)),
                  if (user.address != null && user.address!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('Address', user.address!),
                  ],
                  if (user.dateOfBirth != null) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('DOB', DateFormat('MMM d, yyyy').format(user.dateOfBirth!)),
                  ],
                  if (user.collegeBranch != null && user.collegeBranch!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('Branch', user.collegeBranch!),
                  ],
                  if (user.year != null && user.year!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('Year', user.year!),
                  ],
                  if (user.interests != null && user.interests!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('Interests', user.interests!.join(', ')),
                  ],
                  if (user.skills != null && user.skills!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow('Skills', user.skills!.join(', ')),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (user.status == 'pending' || user.status == 'suspended')
                        _buildActionButton('APPROVE', Icons.check_rounded, const Color(0xFF4CAF50), () => _updateStatus(context, ref, user.uid, 'active')),
                      if (user.status == 'active')
                        _buildActionButton('SUSPEND', Icons.block_rounded, SacredColors.ember, () => _updateStatus(context, ref, user.uid, 'suspended')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w300, letterSpacing: 1, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.jost(fontSize: 9, fontWeight: FontWeight.w200, letterSpacing: 1.5, color: SacredColors.parchment.withOpacity(0.25)),
          ),
        ),
        Expanded(
          child: Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 13, color: SacredColors.parchmentLight.withOpacity(0.65))),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String uid, String newStatus) async {
    try {
      await ref.read(userActionsProvider).updateUserStatus(uid, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: SacredColors.surface),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface),
        );
      }
    }
  }
}

