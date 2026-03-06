import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../providers/admin_provider.dart';
import '../../providers/firebase_provider.dart';

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
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F5F9),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    return Container(
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
      child: activityAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No recent activity',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
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
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final item = displayActivities[index];
                  final timestamp = item['timestamp'] as DateTime?;
                  final timeText = timestamp != null
                      ? _formatTimestamp(timestamp)
                      : '';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (item['color'] as Color).withOpacity(0.12),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    ),
                    title: Text(item['text'] as String, style: const TextStyle(fontSize: 14)),
                    subtitle: timeText.isNotEmpty
                        ? Text(timeText, style: TextStyle(fontSize: 12, color: Colors.grey[500]))
                        : null,
                  );
                },
              ),
              if (!_showAllActivity && activities.length > 3)
                TextButton(
                  onPressed: () => setState(() => _showAllActivity = true),
                  child: const Text('Show more', style: TextStyle(color: Color(0xFF1565C0))),
                ),
              if (_showAllActivity && activities.length > 3)
                TextButton(
                  onPressed: () => setState(() => _showAllActivity = false),
                  child: const Text('Show less', style: TextStyle(color: Color(0xFF1565C0))),
                ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('Failed to load activity', style: TextStyle(color: Colors.grey[500])),
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

