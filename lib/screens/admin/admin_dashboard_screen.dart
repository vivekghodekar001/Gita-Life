import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/firebase_provider.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

// Provider for recent admin activity
final recentActivityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final status = ref.watch(firebaseInitStatusProvider);
  if (status != FirebaseInitStatus.initialized || Firebase.apps.isEmpty) return [];

  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  final results = <Map<String, dynamic>>[];

  // Fetch last 5 attendance sessions
  final sessionsSnap = await firestore
      .collection('attendance_sessions')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .get();
  for (final doc in sessionsSnap.docs) {
    final data = doc.data();
    results.add({
      'type': 'session',
      'icon': Icons.event_available,
      'color': Colors.purple,
      'text': 'Session created: ${data['title'] ?? 'Untitled'}',
      'timestamp': (data['createdAt'] as Timestamp?)?.toDate(),
    });
  }

  // Fetch last 5 new user registrations
  final usersSnap = await firestore
      .collection('users')
      .orderBy('enrollmentDate', descending: true)
      .limit(5)
      .get();
  for (final doc in usersSnap.docs) {
    final data = doc.data();
    results.add({
      'type': 'user',
      'icon': Icons.person_add_alt_1,
      'color': Colors.blue,
      'text': 'New student registered: ${data['fullName'] ?? 'Unknown'}',
      'timestamp': (data['enrollmentDate'] as Timestamp?)?.toDate(),
    });
  }

  // Sort all by timestamp descending and take the 10 most recent
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

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _showAllActivity = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: statsAsync.when(
            data: (stats) => RefreshIndicator(
              color: SacredColors.parchment,
              backgroundColor: SacredColors.surface,
              onRefresh: () => ref.refresh(adminStatsProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 20),
                  _buildStatCircles(stats),
                  const SizedBox(height: 28),
                  SacredSectionLabel(text: 'Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 28),
                  SacredSectionLabel(text: 'Recent Activity'),
                  const SizedBox(height: 12),
                  _buildRecentActivity(ref),
                ],
=======
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF0D47A1), Color(0xFF00695C)],
            ),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8F5F9),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(adminStatsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader('Overview'),
              const SizedBox(height: 16),
              _buildStatsGrid(stats),
              const SizedBox(height: 32),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 16),
              _buildRecentActivity(ref),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Error loading stats: $error', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(adminStatsProvider),
                child: const Text('Retry'),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: SacredColors.ember.withOpacity(0.6), size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading stats', style: SacredTextStyles.infoValue()),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => ref.refresh(adminStatsProvider),
                    child: Text('RETRY', style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(color: SacredColors.parchment.withOpacity(0.5))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
=======
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D1B2A),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Total Students', stats['totalStudents'].toString(), Icons.people, const Color(0xFF1565C0)),
        _buildStatCard('Pending Approvals', stats['pendingApprovals'].toString(), Icons.pending_actions, const Color(0xFF4527A0)),
        _buildStatCard('Active Today', stats['activeToday'].toString(), Icons.local_fire_department, const Color(0xFF00695C)),
        _buildStatCard('Sessions This Week', stats['sessionsThisWeek'].toString(), Icons.event_available, const Color(0xFF00ACC1)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          const Spacer(),
          Text('ADMIN PANEL', style: SacredTextStyles.sectionLabel(fontSize: 10)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStatCircles(Map<String, dynamic> stats) {
    final items = [
      _StatItem('Total\nStudents', stats['totalStudents'] ?? 0, SacredColors.parchment),
      _StatItem('Pending\nApprovals', stats['pendingApprovals'] ?? 0, SacredColors.ember),
      _StatItem('Active\nToday', stats['activeToday'] ?? 0, const Color(0xFF4CAF50)),
      _StatItem('Sessions\nThis Week', stats['sessionsThisWeek'] ?? 0, const Color(0xFF7E57C2)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        return Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color.withOpacity(0.06),
                border: Border.all(color: item.color.withOpacity(0.25), width: 2),
              ),
              child: Center(
                child: Text(
                  '${item.value}',
                  style: GoogleFonts.cormorantSc(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: item.color.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                fontSize: 8,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                color: SacredColors.parchment.withOpacity(0.3),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _ActionItem('Students', Icons.group_add_rounded, '/admin/students', SacredColors.parchment),
      _ActionItem('Lectures', Icons.video_library_rounded, '/admin/lectures', SacredColors.ember),
      _ActionItem('Audio', Icons.library_music_rounded, '/admin/audio', const Color(0xFF4CAF50)),
      _ActionItem('Notifications', Icons.notifications_active_rounded, '/admin/notifications', const Color(0xFF7E57C2)),
      _ActionItem('Attendance', Icons.how_to_reg_rounded, '/admin/attendance', const Color(0xFF29B6F6)),
      _ActionItem('Assignments', Icons.assignment_rounded, '/admin/assignments', const Color(0xFFFFB74D)),
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
<<<<<<< HEAD
      childAspectRatio: 1.0,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => context.push(action.route),
          child: Container(
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: action.color.withOpacity(0.12)),
=======
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(context, 'Manage Students', Icons.group_add, '/admin/students', const Color(0xFF1565C0)),
        _buildActionCard(context, 'Manage Lectures', Icons.video_library, '/admin/lectures', const Color(0xFF1565C0)),
        _buildActionCard(context, 'Manage Audio', Icons.library_music, '/admin/audio', const Color(0xFF1565C0)),
        _buildActionCard(context, 'Send Notifications', Icons.notifications_active, '/admin/notifications', const Color(0xFF1565C0)),
        _buildActionCard(context, 'Manage Attendance', Icons.how_to_reg, '/admin/attendance', const Color(0xFF1565C0)),
        _buildActionCard(context, 'Manage Assignments', Icons.assignment, '/admin/assignments', const Color(0xFF1565C0)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, String route, Color color) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: action.color.withOpacity(0.12)),
                  ),
                  child: Icon(action.icon, size: 22, color: action.color.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: 8,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 1.5,
                    color: action.color.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    return Container(
      decoration: SacredDecorations.glassCard(radius: 14),
      child: activityAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 36, color: SacredColors.parchment.withOpacity(0.12)),
                    const SizedBox(height: 12),
                    Text('No recent activity', style: SacredTextStyles.infoValue().copyWith(
                      color: SacredColors.parchment.withOpacity(0.25),
                    )),
                  ],
                ),
              ),
            );
          }
          final displayActivities = _showAllActivity ? activities : activities.take(3).toList();
          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: displayActivities.length,
                separatorBuilder: (_, __) => SacredDivider(margin: const EdgeInsets.symmetric(horizontal: 16)),
                itemBuilder: (context, index) {
                  final item = displayActivities[index];
                  final timestamp = item['timestamp'] as DateTime?;
                  final timeText = timestamp != null ? _formatTimestamp(timestamp) : '';
                  final color = (item['color'] as Color).withOpacity(0.6);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (item['color'] as Color).withOpacity(0.08),
                        border: Border.all(color: (item['color'] as Color).withOpacity(0.15)),
                      ),
                      child: Icon(item['icon'] as IconData, color: color, size: 16),
                    ),
                    title: Text(
                      item['text'] as String,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 13, color: SacredColors.parchmentLight.withOpacity(0.7),
                      ),
                    ),
                    subtitle: timeText.isNotEmpty
                        ? Text(timeText, style: GoogleFonts.jost(
                            fontSize: 10, fontWeight: FontWeight.w300,
                            color: SacredColors.parchment.withOpacity(0.2),
                          ))
                        : null,
                  );
                },
              ),
              if (!_showAllActivity && activities.length > 3)
<<<<<<< HEAD
                GestureDetector(
                  onTap: () => setState(() => _showAllActivity = true),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('SHOW MORE', style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(
                      color: SacredColors.parchment.withOpacity(0.4),
                    )),
                  ),
                ),
              if (_showAllActivity && activities.length > 3)
                GestureDetector(
                  onTap: () => setState(() => _showAllActivity = false),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('SHOW LESS', style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(
                      color: SacredColors.parchment.withOpacity(0.4),
                    )),
                  ),
=======
                TextButton(
                  onPressed: () => setState(() => _showAllActivity = true),
                  child: const Text('Show more', style: TextStyle(color: Color(0xFF1565C0))),
                ),
              if (_showAllActivity && activities.length > 3)
                TextButton(
                  onPressed: () => setState(() => _showAllActivity = false),
                  child: const Text('Show less', style: TextStyle(color: Color(0xFF1565C0))),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                ),
            ],
          );
        },
<<<<<<< HEAD
        loading: () => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.5))),
=======
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('Failed to load activity', style: SacredTextStyles.infoValue().copyWith(
              color: SacredColors.parchment.withOpacity(0.25),
            )),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}

class _ActionItem {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _ActionItem(this.label, this.icon, this.route, this.color);
}

