import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/preaching_provider.dart';
import '../../models/app_user.dart';
import '../../models/session.dart';

// ─── Color constants ─────────────────────────────────────────────────────────
const _saffron = Color(0xFFFF6600);
const _gold = Color(0xFFD4A017);
const _cream = Color(0xFFFFF8F0);
const _navy = Color(0xFF1A1A2E);
const _green = Color(0xFF1D9E75);
const _amber = Color(0xFFBA7517);
const _red = Color(0xFFE24B4A);

// ─────────────────────────────────────────────────────────────────────────────
//  PreachingScreen — entry point
// ─────────────────────────────────────────────────────────────────────────────

class PreachingScreen extends ConsumerWidget {
  const PreachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(activeSessionProvider);

    return Scaffold(
      backgroundColor: _cream,
      body: activeSessionAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _saffron)),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (session) => _PreachingBody(session: session),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main body — displayed once session is loaded
// ─────────────────────────────────────────────────────────────────────────────

class _PreachingBody extends ConsumerWidget {
  final Session? session;
  const _PreachingBody({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devoteesAsync = ref.watch(myDevoteesProvider);
    final filter = ref.watch(preachingFilterProvider);

    // Attendance map for current session (devoteeId → status)
    final attendanceAsync = session != null
        ? ref.watch(sessionAttendanceProvider(session!.id))
        : const AsyncValue<Map<String, String>>.data({});

    final attendance = attendanceAsync.valueOrNull ?? {};

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ──
          _TopBar(session: session),

          // ── Stats Row ──
          devoteesAsync.when(
            loading: () => const SizedBox(height: 72),
            error: (_, __) => const SizedBox(height: 72),
            data: (devotees) =>
                _StatsRow(devotees: devotees, attendance: attendance),
          ),

          // ── Filter Pills ──
          _FilterPills(),

          // ── Devotee List ──
          Expanded(
            child: devoteesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _saffron)),
              error: (e, _) => _ErrorView(message: e.toString()),
              data: (devotees) {
                if (session == null) {
                  return _NoSessionView();
                }
                return _DevoteeList(
                  devotees: devotees,
                  filter: filter,
                  session: session!,
                  attendance: attendance,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final Session? session;
  const _TopBar({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = session != null
        ? DateFormat('EEE, d MMM yyyy').format(session!.date)
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back arrow
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _navy.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: _navy),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREACHING',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: _navy.withOpacity(0.5))),
                if (session != null) ...[
                  Text(session!.title,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _navy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('By ${session!.speaker} · $dateStr',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _navy.withOpacity(0.55))),
                ] else
                  Text('No active session',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _navy.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<AppUser> devotees;
  final Map<String, String> attendance;
  const _StatsRow({required this.devotees, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final confirmed =
        devotees.where((d) => attendance[d.uid] == 'Coming').length;
    final notReachable =
        devotees.where((d) => attendance[d.uid] == 'Not Reachable').length;
    // Pending = devotees with no status yet (not yet contacted)
    final pending = devotees
        .where((d) => attendance[d.uid] == null)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _StatBox(label: 'Confirmed', value: confirmed, color: _green),
          const SizedBox(width: 10),
          _StatBox(label: 'Pending', value: pending, color: _amber),
          const SizedBox(width: 10),
          _StatBox(label: 'Not Reachable', value: notReachable, color: _red),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8)),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter Pills
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPills extends ConsumerWidget {
  static const _filters = [
    'All',
    'Coming',
    'At Home',
    'Not Reachable',
    'Absent'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(preachingFilterProvider);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final f = _filters[i];
          final isSelected = f == selected;
          return GestureDetector(
            onTap: () =>
                ref.read(preachingFilterProvider.notifier).state = f,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? _navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isSelected ? _navy : _navy.withOpacity(0.18)),
              ),
              child: Text(f,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : _navy.withOpacity(0.65))),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Devotee List (two sections: Sincere + Not Sincere)
// ─────────────────────────────────────────────────────────────────────────────

class _DevoteeList extends ConsumerWidget {
  final List<AppUser> devotees;
  final String filter;
  final Session session;
  final Map<String, String> attendance;

  const _DevoteeList({
    required this.devotees,
    required this.filter,
    required this.session,
    required this.attendance,
  });

  List<AppUser> _applyFilter(List<AppUser> list) {
    if (filter == 'All') return list;
    return list
        .where((d) => attendance[d.uid] == filter)
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Split by category (already sorted by attendanceScore in provider)
    final sincere =
        _applyFilter(devotees.where((d) => d.category == 'Sincere').toList());
    final notSincere = _applyFilter(
        devotees.where((d) => d.category == 'Not Sincere').toList());

    final recentSessionsAsync = ref.watch(recentSessionsProvider);
    final recentAttendanceAsync = ref.watch(recentAttendanceMapProvider);

    final recentSessions = recentSessionsAsync.valueOrNull ?? [];
    final recentAttendanceMap = recentAttendanceAsync.valueOrNull ?? {};

    if (sincere.isEmpty && notSincere.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: _navy.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              filter == 'All'
                  ? 'No devotees assigned yet'
                  : 'No devotees with "$filter" status',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _navy.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        // ── Sincere Section ──
        if (sincere.isNotEmpty) ...[
          _SectionHeader(title: 'Sincere'),
          const SizedBox(height: 8),
          ...sincere.asMap().entries.map((e) => _DevoteeCard(
                devotee: e.value,
                rank: e.key + 1,
                showRank: true,
                currentStatus: attendance[e.value.uid],
                session: session,
                recentSessions: recentSessions,
                recentAttendance: recentAttendanceMap[e.value.uid] ?? {},
              )),
          const SizedBox(height: 16),
        ],

        // ── Not Sincere Section ──
        if (notSincere.isNotEmpty) ...[
          _SectionHeader(title: 'Not Sincere'),
          const SizedBox(height: 8),
          ...notSincere.asMap().entries.map((e) => _DevoteeCard(
                devotee: e.value,
                rank: e.key + 1,
                showRank: false,
                currentStatus: attendance[e.value.uid],
                session: session,
                recentSessions: recentSessions,
                recentAttendance: recentAttendanceMap[e.value.uid] ?? {},
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title.toUpperCase(),
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: _navy.withOpacity(0.5))),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: _navy.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Devotee Card
// ─────────────────────────────────────────────────────────────────────────────

class _DevoteeCard extends StatelessWidget {
  final AppUser devotee;
  final int rank;
  final bool showRank;
  final String? currentStatus;
  final Session session;
  final List<Session> recentSessions;
  final Map<String, String> recentAttendance;

  const _DevoteeCard({
    required this.devotee,
    required this.rank,
    required this.showRank,
    required this.currentStatus,
    required this.session,
    required this.recentSessions,
    required this.recentAttendance,
  });

  Color _avatarColor() {
    if (devotee.attendanceScore > 5) return _green;
    if (devotee.attendanceScore >= 0) return _amber;
    return _red;
  }

  String _initials() {
    final parts = devotee.name.trim().split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _navy.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Rank + Avatar + Name + Call ──
            Row(
              children: [
                // Rank badge (Sincere only)
                if (showRank)
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withOpacity(0.15),
                      border: Border.all(color: _gold.withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text('$rank',
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _gold)),
                    ),
                  ),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarColor().withOpacity(0.15),
                    border:
                        Border.all(color: _avatarColor().withOpacity(0.5)),
                  ),
                  child: Center(
                    child: Text(_initials(),
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _avatarColor())),
                  ),
                ),
                const SizedBox(width: 10),
                // Name + year
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(devotee.name,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _navy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          '${devotee.year.isNotEmpty ? '${devotee.year} · ' : ''}${devotee.mobile}',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _navy.withOpacity(0.5))),
                    ],
                  ),
                ),
                // Call button
                _CallButton(mobile: devotee.mobile),
              ],
            ),

            const SizedBox(height: 10),

            // ── Row 2: History dots ──
            _HistoryDots(
                recentSessions: recentSessions,
                recentAttendance: recentAttendance),

            const SizedBox(height: 10),

            // ── Row 3: Status pills ──
            _StatusPills(
              devoteeId: devotee.uid,
              sessionId: session.id,
              currentStatus: currentStatus,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Call Button
// ─────────────────────────────────────────────────────────────────────────────

class _CallButton extends StatelessWidget {
  final String mobile;
  const _CallButton({required this.mobile});

  Future<void> _call() async {
    final uri = Uri.parse('tel:$mobile');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: mobile.isNotEmpty ? _call : null,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 13, color: Color(0xFF1565C0)),
            const SizedBox(width: 4),
            Text('CALL',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  History Dots (last 4 sessions)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryDots extends StatelessWidget {
  final List<Session> recentSessions;
  final Map<String, String> recentAttendance;

  const _HistoryDots({
    required this.recentSessions,
    required this.recentAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...recentSessions.map((s) {
          final status = recentAttendance[s.id];
          return _buildDot(status);
        }),
        if (recentSessions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text('← older',
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _navy.withOpacity(0.35))),
          ),
      ],
    );
  }

  Widget _buildDot(String? status) {
    Color color;
    String label;

    switch (status) {
      case 'Present':
        color = _green;
        label = 'P';
        break;
      case 'Absent':
        color = _red;
        label = 'A';
        break;
      case 'At Home':
        color = _amber;
        label = 'H';
        break;
      case 'Coming':
        color = _green.withOpacity(0.7);
        label = 'C';
        break;
      case 'Not Reachable':
        color = _red.withOpacity(0.7);
        label = 'N';
        break;
      default:
        color = _navy.withOpacity(0.2);
        label = '–';
    }

    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Center(
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Status Pills (Coming / At Home / Not Reachable / Absent)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPills extends StatelessWidget {
  final String devoteeId;
  final String sessionId;
  final String? currentStatus;

  static const _statuses = ['Coming', 'At Home', 'Not Reachable', 'Absent'];

  static const _colors = {
    'Coming': _green,
    'At Home': _amber,
    'Not Reachable': _red,
    'Absent': _navy,
  };

  const _StatusPills({
    required this.devoteeId,
    required this.sessionId,
    required this.currentStatus,
  });

  Future<void> _markAttendance(
      BuildContext context, String status) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final recordId = '${devoteeId}_$sessionId';
    try {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(recordId)
          .set({
        'devoteeId': devoteeId,
        'sessionId': sessionId,
        'status': status,
        'markedBy': uid,
        'markedAt': FieldValue.serverTimestamp(),
      });
      // Update attendance score asynchronously
      _updateScore(devoteeId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _updateScore(String devId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('attendance')
          .where('devoteeId', isEqualTo: devId)
          .get();

      int score = 0;
      for (final doc in snap.docs) {
        final s = doc.data()['status'] as String? ?? '';
        switch (s) {
          case 'Present':
            score += 3;
            break;
          case 'Coming':
            score += 1;
            break;
          case 'At Home':
            score += 0;
            break;
          case 'Not Reachable':
            score -= 1;
            break;
          case 'Absent':
            score -= 1;
            break;
        }
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(devId)
          .update({'attendanceScore': score});
    } catch (_) {
      // Fire-and-forget: score update failure does not block attendance marking.
      // The score will self-correct on the next successful update.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _statuses.map((s) {
        final isSelected = s == currentStatus;
        final c = _colors[s]!;
        return GestureDetector(
          onTap: () => _markAttendance(context, s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? c : c.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? c : c.withOpacity(0.3)),
            ),
            child: Text(s,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : c.withOpacity(0.8))),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NoSessionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy,
              size: 56, color: _navy.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text('No Active Session',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _navy.withOpacity(0.4))),
          const SizedBox(height: 6),
          Text('Ask admin to create a session first.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: _navy.withOpacity(0.3))),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _red),
            const SizedBox(height: 12),
            Text('Something went wrong',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navy)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: _navy.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
