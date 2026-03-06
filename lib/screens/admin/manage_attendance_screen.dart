import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_session.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class ManageAttendanceScreen extends ConsumerWidget {
  const ManageAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionListProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: SacredColors.parchment.withOpacity(0.4)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text('Manage Attendance', style: SacredTextStyles.sectionLabel())),
                  ],
                ),
              ),
              // ── Sessions ──
              Expanded(
                child: sessionsAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 48, color: SacredColors.parchment.withOpacity(0.15)),
                            const SizedBox(height: 14),
                            Text('No attendance sessions yet.', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
                            const SizedBox(height: 6),
                            Text('Create a session to get started.', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.2))),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: SacredColors.parchment.withOpacity(0.3),
                      backgroundColor: SacredColors.surface,
                      onRefresh: () => ref.refresh(sessionListProvider.future),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: sessions.length,
                        itemBuilder: (_, i) => _SessionCard(session: sessions[i]),
                      ),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.2), strokeWidth: 1.5)),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: SacredColors.ember.withOpacity(0.3), size: 48),
                        const SizedBox(height: 14),
                        Text('Error: $e', textAlign: TextAlign.center, style: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.3))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => ref.invalidate(sessionListProvider),
                          child: Text('RETRY', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: SacredColors.parchment.withOpacity(0.5))),
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
      floatingActionButton: GestureDetector(
        onTap: () => _showCreateSessionDialog(context, ref),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: SacredColors.surface,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: SacredColors.parchment.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text('CREATE SESSION', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1, color: SacredColors.parchment.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateSessionDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final topicController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SacredColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Create New Session', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.8))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sacredDialogField(titleController, 'Session Title', 'e.g. BG Chapter 1'),
                const SizedBox(height: 14),
                _sacredDialogField(topicController, 'Topic', 'e.g. Introduction to the Gita'),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(primary: SacredColors.parchment, surface: SacredColors.surface),
                      ), child: child!),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
                      filled: true,
                      fillColor: SacredColors.parchment.withOpacity(0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM d, yyyy').format(selectedDate), style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7))),
                        Icon(Icons.calendar_today, size: 15, color: SacredColors.parchment.withOpacity(0.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.4)))),
            GestureDetector(
              onTap: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Enter a session title.'), backgroundColor: SacredColors.surface));
                  return;
                }
                Navigator.pop(context);
                try {
                  await ref.read(createSessionProvider({
                    'title': title,
                    'topic': topicController.text.trim(),
                    'date': selectedDate,
                  }).future);
                  ref.invalidate(sessionListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Session created.'), backgroundColor: SacredColors.surface));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface));
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: SacredColors.parchment.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                ),
                child: Text('CREATE', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: SacredColors.parchmentLight.withOpacity(0.6))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sacredDialogField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
        hintStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.2)),
        filled: true,
        fillColor: SacredColors.parchment.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final AttendanceSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = session.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: SacredDecorations.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title, style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.7))),
                    const SizedBox(height: 3),
                    Text(session.topic, style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
                    const SizedBox(height: 3),
                    Text(DateFormat('MMM d, yyyy').format(session.lectureDate), style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.25))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (isLocked ? SacredColors.parchment : SacredColors.ember).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (isLocked ? SacredColors.parchment : SacredColors.ember).withOpacity(0.15)),
                ),
                child: Text(
                  isLocked ? 'LOCKED' : 'OPEN',
                  style: GoogleFonts.jost(fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.8, color: (isLocked ? SacredColors.parchment : SacredColors.ember).withOpacity(0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statChip(Icons.check_circle_outline, '${session.presentCount}', const Color(0xFF4CAF50)),
              const SizedBox(width: 10),
              _statChip(Icons.cancel_outlined, '${session.absentCount}', SacredColors.ember),
              const SizedBox(width: 10),
              _statChip(Icons.watch_later_outlined, '${session.lateCount}', SacredColors.parchment),
              const SizedBox(width: 10),
              _statChip(Icons.people_outline, '${session.totalStudents}', const Color(0xFF42A5F5)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLocked)
                _actionButton(
                  label: 'MARK',
                  icon: Icons.how_to_reg,
                  color: SacredColors.ember,
                  onTap: () => context.push('/admin/attendance/mark/${session.sessionId}'),
                ),
              if (!isLocked) const SizedBox(width: 8),
              _actionButton(
                label: isLocked ? 'UNLOCK' : 'LOCK',
                icon: isLocked ? Icons.lock_open : Icons.lock_outline,
                color: SacredColors.parchment,
                onTap: () => _toggleLock(context, ref, session),
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'DELETE',
                icon: Icons.delete_outline,
                color: SacredColors.ember,
                onTap: () => _deleteSession(context, ref, session),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color.withOpacity(0.5)),
        const SizedBox(width: 3),
        Text(value, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, color: color.withOpacity(0.6))),
      ],
    );
  }

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.jost(fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: color.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLock(BuildContext context, WidgetRef ref, AttendanceSession session) async {
    try {
      final service = ref.read(attendanceServiceProvider);
      if (session.isLocked) {
        await service.unlockSession(session.sessionId);
      } else {
        await service.submitSession(session.sessionId);
      }
      ref.invalidate(sessionListProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface));
      }
    }
  }

  Future<void> _deleteSession(BuildContext context, WidgetRef ref, AttendanceSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SacredColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Session', style: GoogleFonts.cormorantGaramond(color: SacredColors.parchmentLight.withOpacity(0.8))),
        content: Text('Delete "${session.title}"? All attendance records will also be deleted.',
            style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.4)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: SacredColors.ember.withOpacity(0.7)))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(attendanceServiceProvider).deleteSession(session.sessionId);
        ref.invalidate(sessionListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Session deleted.'), backgroundColor: SacredColors.surface));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface));
        }
      }
    }
  }
}
