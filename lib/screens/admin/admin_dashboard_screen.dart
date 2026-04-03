import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/firebase_provider.dart';
import '../../widgets/sacred_widgets.dart';
import '../../app/sacred_theme.dart';

// Provider for recent admin activity
final recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final status = ref.watch(firebaseInitStatusProvider);
  if (status != FirebaseInitStatus.initialized || Firebase.apps.isEmpty)
    return [];

  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  final results = <Map<String, dynamic>>[];

  final sessionsSnap = await firestore
      .collection('attendance_sessions')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .get();
  for (final doc in sessionsSnap.docs) {
    final data = doc.data();
    results.add({
      'text': 'Session: ${data['title'] ?? 'Untitled'}',
      'timestamp': (data['createdAt'] as Timestamp?)?.toDate(),
    });
  }

  final usersSnap = await firestore
      .collection('users')
      .orderBy('enrollmentDate', descending: true)
      .limit(5)
      .get();
  for (final doc in usersSnap.docs) {
    final data = doc.data();
    results.add({
      'text': 'New student: ${data['fullName'] ?? 'Unknown'}',
      'timestamp': (data['enrollmentDate'] as Timestamp?)?.toDate(),
    });
  }

  results.sort((a, b) {
    final ta = a['timestamp'] as DateTime?;
    final tb = b['timestamp'] as DateTime?;
    if (ta == null && tb == null) return 0;
    if (ta == null) return 1;
    if (tb == null) return -1;
    return tb.compareTo(ta);
  });

  return results.take(10).toList();
});

// Provider: list of counselors with their assigned devotee count
final counselorsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final status = ref.watch(firebaseInitStatusProvider);
  if (status != FirebaseInitStatus.initialized || Firebase.apps.isEmpty) {
    return const Stream.empty();
  }
  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  return firestore
      .collection('users')
      .where('role', isEqualTo: 'counselor')
      .snapshots()
      .asyncMap((snap) async {
    final counselors = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      int devoteeCount = 0;
      try {
        final devoteesSnap = await firestore
            .collection('users')
            .where('counselorUid', isEqualTo: doc.id)
            .get();
        devoteeCount = devoteesSnap.docs.length;
      } catch (_) {
        // Silently use default count of 0 if the query fails.
      }
      counselors.add({
        'uid': doc.id,
        'name': data['name'] as String? ??
            data['fullName'] as String? ??
            'Unknown',
        'devoteeCount': devoteeCount,
      });
    }
    return counselors;
  });
});

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Admin Dashboard Screen
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _showAllActivity = false;
  int _navIndex = -1;

  static const _bgPage = Color(0xFFE8E0CC);
  static const _inkDark = Color(0xBF32230A);
  static const _inkMid = Color(0x80503710);
  static const _inkFaint = Color(0x4D644B14);

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: statsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B6914))),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFC85010), size: 48),
                  const SizedBox(height: 12),
                  Text('Error loading stats',
                      style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.w600, color: _inkMid)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => ref.refresh(adminStatsProvider),
                    child: Text('RETRY',
                        style: GoogleFonts.cinzel(
                            fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2, color: _inkFaint)),
                  ),
                ],
              ),
            ),
            data: (stats) => RefreshIndicator(
              color: const Color(0xFF8B6914),
              backgroundColor: Colors.white,
              onRefresh: () => ref.refresh(adminStatsProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
                children: [
                  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildHeader(context),
                  const SizedBox(height: 36),

                  // â”€â”€ Stat Circles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildStatCircles(stats),
                  const SizedBox(height: 40),

                  // â”€â”€ Section header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 16),

                  // â”€â”€ Action Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildActionGrid(context),
                  const SizedBox(height: 32),

                  // ── Counselor Management ─────────────────────────────────
                  _buildSectionHeader('Counselors'),
                  const SizedBox(height: 16),
                  _buildCounselorSection(context, ref),
                  const SizedBox(height: 32),

                  // ── Recent Activity ─────────────────────────────────────
                  _buildSectionHeader('Recent Activity'),
                  const SizedBox(height: 12),
                  _buildRecentActivity(ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x80F0E4C3),
              border: Border.all(color: const Color(0x59B48C28), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(Icons.chevron_left_rounded, size: 20, color: _inkMid),
          ),
        ),
        const Spacer(),
        Text('ADMIN PANEL',
            style: GoogleFonts.cinzel(
                fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 4.5, color: _inkMid)),
        const Spacer(),
        // Invisible spacer to keep title perfectly centred
        const SizedBox(width: 36, height: 36),
      ],
    );
  }

  // â”€â”€ Stat Circles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStatCircles(Map<String, dynamic> stats) {
    final items = [
      _StatDef(
          'Total\nStudents', '${stats['totalStudents'] ?? 0}', _ConicType.gold),
      _StatDef('Pending\nApprovals', '${stats['pendingApprovals'] ?? 0}',
          _ConicType.coral),
      _StatDef(
          'Active\nStudents', '${stats['activeToday'] ?? 0}', _ConicType.sage),
      _StatDef(
          'Total\nChapters',
          '${stats['totalChapters'] ?? stats['sessionsThisWeek'] ?? 0}',
          _ConicType.lavender),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + i * 100),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(0, 12 * (1 - v)), child: child),
          ),
          child: Column(
            children: [
              _ConicCircle(value: item.value, type: item.type),
              const SizedBox(height: 10),
              Text(
                item.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: _inkFaint,
                    height: 1.5),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // â”€â”€ Section Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title.toUpperCase(),
            style: GoogleFonts.cinzel(
                fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 3.5, color: _inkFaint)),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x40B48C28), Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Action Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionDef('Students', _CardColor.neutral, Icons.people_outline_rounded,
          '/admin/students'),
      _ActionDef('Lectures', _CardColor.coral, Icons.videocam_outlined,
          '/admin/lectures'),
      _ActionDef(
          'Audio', _CardColor.sage, Icons.music_note_outlined, '/admin/audio'),
      _ActionDef('Assignments', _CardColor.lavender, Icons.assignment_outlined,
          '/admin/assignments'),
      _ActionDef('Attendance', _CardColor.sky, Icons.how_to_reg_outlined,
          '/admin/attendance'),
      _ActionDef('Notifications', _CardColor.neutral,
          Icons.notifications_none_rounded, '/admin/notifications'),
      _ActionDef('Devotee\nAssign', _CardColor.lavender,
          Icons.supervisor_account_rounded, '/admin/manage-devotee-assignments'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + i * 100),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(0, 14 * (1 - v)), child: child),
          ),
          child: _ActionCard(action: a, onTap: () => context.push(a.route)),
        );
      },
    );
  }

  // â”€â”€ Recent Activity â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  // ── Counselor Management Section ──────────────────────────────────────────
  Widget _buildCounselorSection(BuildContext context, WidgetRef ref) {
    final counselorsAsync = ref.watch(counselorsProvider);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33F0E8D0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x59D4A017)), // gold border
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
            child: Row(
              children: [
                counselorsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33D4A017),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x59D4A017)),
                    ),
                    child: Text(
                      '${list.length} active',
                      style: GoogleFonts.cinzel(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B6914)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Counselor Management',
                    style: GoogleFonts.cinzel(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFF7A5008))),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/admin/counselors'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('Assign +',
                            style: GoogleFonts.jost(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/admin/manage-devotee-assignments'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4A017)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.settings_outlined, size: 14, color: Color(0xFFD4A017)),
                        const SizedBox(width: 4),
                        Text('Manage All',
                            style: GoogleFonts.jost(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: const Color(0xFFD4A017))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Counselor list
          counselorsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF8B6914), strokeWidth: 1.5)),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load counselors',
                  style: GoogleFonts.jost(fontSize: 12, color: const Color(0x80B48C28))),
            ),
            data: (counselors) {
              if (counselors.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No counselors assigned yet.',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 13, color: const Color(0x80B48C28))),
                  ),
                );
              }
              return Column(
                children: counselors.map((c) {
                  final name = c['name'] as String? ?? 'Unknown';
                  final count = c['devoteeCount'] as int? ?? 0;
                  final initials = name.trim().split(' ').take(2)
                      .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                      .join();
                  return Column(
                    children: [
                      Divider(color: const Color(0x1AB48C28), height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x33D4A017),
                            border: Border.all(color: const Color(0x59D4A017)),
                          ),
                          child: Center(
                            child: Text(initials,
                                style: GoogleFonts.cinzel(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8B6914))),
                          ),
                        ),
                        title: Text(name,
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 15, fontWeight: FontWeight.w600,
                                color: const Color(0xFF7A5008))),
                        subtitle: Text('$count devotees assigned',
                            style: GoogleFonts.jost(
                                fontSize: 11, color: const Color(0x80B48C28))),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x26D4A017),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x40D4A017)),
                          ),
                          child: Text('Counselor',
                              style: GoogleFonts.cinzel(
                                  fontSize: 9, fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B6914))),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33F0E8D0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x26B48C28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: activityAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF8B6914), strokeWidth: 1.5)),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: Text('Failed to load activity',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 13, color: _inkFaint))),
        ),
        data: (activities) {
          if (activities.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                  child: Text('No recent activity',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 14, color: _inkFaint))),
            );
          }
          final shown =
              _showAllActivity ? activities : activities.take(4).toList();
          return Column(
            children: [
              ...shown.asMap().entries.map((e) {
                final item = e.value;
                final ts = item['timestamp'] as DateTime?;
                final timeStr = ts != null ? _formatTs(ts) : '';
                return Column(
                  children: [
                    if (e.key > 0)
                      Divider(
                          color: const Color(0x1AB48C28),
                          height: 1,
                          indent: 16,
                          endIndent: 16),
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x1AD4AF37),
                          border: Border.all(color: const Color(0x26B48C28)),
                        ),
                        child: Icon(Icons.history_rounded,
                            size: 14, color: _inkFaint),
                      ),
                      title: Text(item['text'] as String,
                          style: GoogleFonts.cormorantGaramond(
                              fontSize: 15, fontWeight: FontWeight.w600, color: _inkDark.withOpacity(0.7))),
                      trailing: timeStr.isNotEmpty
                          ? Text(timeStr,
                              style: GoogleFonts.jost(
                                  fontSize: 12, fontWeight: FontWeight.w500, color: _inkFaint))
                          : null,
                    ),
                  ],
                );
              }),
              if (!_showAllActivity && activities.length > 4)
                GestureDetector(
                  onTap: () => setState(() => _showAllActivity = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('SHOW MORE',
                        style: GoogleFonts.cinzel(
                            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.5, color: _inkFaint)),
                  ),
                ),
              if (_showAllActivity && activities.length > 4)
                GestureDetector(
                  onTap: () => setState(() => _showAllActivity = false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('SHOW LESS',
                        style: GoogleFonts.cinzel(
                            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.5, color: _inkFaint)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatTs(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Conic-gradient stat circle
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum _ConicType { gold, coral, sage, lavender }

class _ConicCircle extends StatelessWidget {
  final String value;
  final _ConicType type;
  const _ConicCircle({required this.value, required this.type});

  static const _rings = {
    _ConicType.gold: [
      Color(0x99D4AF37),
      Color(0xCCF0C850),
      Color(0x4DD4AF37),
      Color(0x80B48C1E)
    ],
    _ConicType.coral: [
      Color(0x80D27850),
      Color(0xB3E69664),
      Color(0x33D27850),
      Color(0x66BE643C)
    ],
    _ConicType.sage: [
      Color(0x8064A06E),
      Color(0xB382B982),
      Color(0x3364A06E),
      Color(0x66508C5A)
    ],
    _ConicType.lavender: [
      Color(0x80966EBE),
      Color(0xB3B48CD2),
      Color(0x33966EBE),
      Color(0x66825AAA)
    ],
  };

  static const _textColors = {
    _ConicType.gold: Color(0xFF7A5008),
    _ConicType.coral: Color(0xFFA04020),
    _ConicType.sage: Color(0xFF2D6B3A),
    _ConicType.lavender: Color(0xFF5A2D8A),
  };

  @override
  Widget build(BuildContext context) {
    final stops = _rings[type]!;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [...stops, stops[0]]),
        boxShadow: [
          BoxShadow(
              color: stops[0].withOpacity(0.35),
              blurRadius: 14,
              spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5EEDB), Color(0xFFEDE0C0)],
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: _textColors[type],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Action Card
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum _CardColor { neutral, coral, sage, lavender, sky }

class _ActionDef {
  final String label;
  final _CardColor color;
  final IconData icon;
  final String route;
  const _ActionDef(this.label, this.color, this.icon, this.route);
}

class _ActionCard extends StatefulWidget {
  final _ActionDef action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovering = false;

  static const _gradients = {
    _CardColor.neutral: [Color(0xB2EDE5CE), Color(0xCCD7CDB2)],
    _CardColor.coral: [Color(0xA6F0D2BE), Color(0xBFE1BEA5)],
    _CardColor.sage: [Color(0xA6CDEAD5), Color(0xBFB9D2BE)],
    _CardColor.lavender: [Color(0xA6DCD2EB), Color(0xBFC8BEDC)],
    _CardColor.sky: [Color(0xA6C3DCE8), Color(0xBFAFCDE1)],
  };

  static const _borders = {
    _CardColor.neutral: Color(0x40B49C3C),
    _CardColor.coral: Color(0x33C87850),
    _CardColor.sage: Color(0x3364A06E),
    _CardColor.lavender: Color(0x33966EBE),
    _CardColor.sky: Color(0x33508CBE),
  };

  static const _iconBg = {
    _CardColor.neutral: [Color(0x40D4AF37), Color(0x26B48C1E)],
    _CardColor.coral: [Color(0x40D27850), Color(0x26BE643C)],
    _CardColor.sage: [Color(0x4064A06E), Color(0x2650885A)],
    _CardColor.lavender: [Color(0x40966EBE), Color(0x26825AAA)],
    _CardColor.sky: [Color(0x40508CBE), Color(0x26326EAA)],
  };

  static const _iconBorder = {
    _CardColor.neutral: Color(0x73B48C28),
    _CardColor.coral: Color(0x66C8643C),
    _CardColor.sage: Color(0x665A9664),
    _CardColor.lavender: Color(0x66906EBA),
    _CardColor.sky: Color(0x66468CBE),
  };

  static const _iconColor = {
    _CardColor.neutral: Color(0xFF8B5E0A),
    _CardColor.coral: Color(0xFFA04020),
    _CardColor.sage: Color(0xFF2D6B3A),
    _CardColor.lavender: Color(0xFF5A2D8A),
    _CardColor.sky: Color(0xFF1A5A8A),
  };

  static const _labelColor = {
    _CardColor.neutral: Color(0x99644615),
    _CardColor.coral: Color(0x99904623),
    _CardColor.sage: Color(0x992D6B3A),
    _CardColor.lavender: Color(0x995A3282),
    _CardColor.sky: Color(0x991E5082),
  };

  @override
  Widget build(BuildContext context) {
    final c = widget.action.color;
    final gradColors = _gradients[c]!;
    final iconBgColors = _iconBg[c]!;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.34, 1.56, 0.64, 1),
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0)
            ..scale(_hovering ? 1.01 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: const Alignment(-0.7, -0.7),
              end: const Alignment(0.7, 0.7),
              colors: gradColors,
            ),
            border: Border.all(color: _borders[c]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.12 : 0.06),
                blurRadius: _hovering ? 28 : 16,
                offset: const Offset(0, 4),
              ),
              if (_hovering)
                BoxShadow(
                    color: _borders[c]!.withOpacity(0.6),
                    blurRadius: 0,
                    spreadRadius: 1.5),
            ],
          ),
          child: Stack(
            children: [
              // â”€â”€ Corner decoration (top-left) â”€â”€
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x33D4AF37)),
                      left: BorderSide(color: Color(0x33D4AF37)),
                    ),
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(3)),
                  ),
                ),
              ),
              // â”€â”€ Corner decoration (bottom-right) â”€â”€
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x33D4AF37)),
                      right: BorderSide(color: Color(0x33D4AF37)),
                    ),
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(3)),
                  ),
                ),
              ),
              // â”€â”€ Content â”€â”€
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: const Cubic(0.34, 1.56, 0.64, 1),
                      width: 52,
                      height: 52,
                      transform:
                          Matrix4.translationValues(0, _hovering ? -2 : 0, 0)
                            ..scale(_hovering ? 1.12 : 1.0),
                      transformAlignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: iconBgColors,
                        ),
                        border: Border.all(color: _iconBorder[c]!, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _iconBorder[c]!.withOpacity(0.6),
                              blurRadius: 14,
                              spreadRadius: 4),
                          BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Icon(widget.action.icon,
                          size: 20, color: _iconColor[c]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.action.label.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: _labelColor[c],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Data classes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StatDef {
  final String label;
  final String value;
  final _ConicType type;
  const _StatDef(this.label, this.value, this.type);
}

class _GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _BarItem(icon: Icons.radio_button_checked_rounded, label: 'Japa'),
    _BarItem(icon: Icons.play_circle_outline_rounded, label: 'Video'),
    _BarItem(icon: Icons.headphones_rounded, label: 'Audio'),
    _BarItem(icon: Icons.assignment_rounded, label: 'Assignment'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(0.7, 1),
            colors: [Color(0xD9F0E4C3), Color(0xE6DCD5A5)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x80B48C28), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 8)),
            BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.18),
                blurRadius: 10,
                spreadRadius: 1),
            const BoxShadow(
                color: Color(0x55FFE678), blurRadius: 1, offset: Offset(0, -1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length * 2 - 1, (idx) {
              if (idx.isOdd) {
                // Vertical gold divider
                return Container(
                  width: 1,
                  height: 26,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x408B6914),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              }
              final i = idx ~/ 2;
              final item = _items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: const Cubic(0.34, 1.56, 0.64, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: isActive
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x40D4AF37), Color(0x26B48C1E)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: const Color(0x66B48C28), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA07814).withOpacity(0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            size: 19,
                            color: isActive
                                ? const Color(0xFF8B5E0A)
                                : const Color(0xFF64461A).withOpacity(0.42),
                          ),
                          if (isActive)
                            Positioned(
                              bottom: -5,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFF0C040)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37)
                                          .withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isActive
                              ? const Color(0xFF7A5008)
                              : const Color(0xFF64461A).withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BarItem {
  final IconData icon;
  final String label;
  const _BarItem({required this.icon, required this.label});
}
