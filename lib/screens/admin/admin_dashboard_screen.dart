import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFF8F0),
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
              _buildRecentActivityPlaceholder(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE65100))),
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
        color: Color(0xFF3E2723),
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
        _buildStatCard('Total Students', stats['totalStudents'].toString(), Icons.people, Colors.blue),
        _buildStatCard('Pending Approvals', stats['pendingApprovals'].toString(), Icons.pending_actions, Colors.orange),
        _buildStatCard('Active Today', stats['activeToday'].toString(), Icons.local_fire_department, Colors.green),
        _buildStatCard('Sessions This Week', stats['sessionsThisWeek'].toString(), Icons.event_available, Colors.purple),
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
        _buildActionCard(context, 'Manage Students', Icons.group_add, '/admin/students', const Color(0xFFE65100)),
        _buildActionCard(context, 'Manage Lectures', Icons.video_library, '/admin/lectures', const Color(0xFFE65100)),
        _buildActionCard(context, 'Manage Audio', Icons.library_music, '/admin/audio', const Color(0xFFE65100)),
        _buildActionCard(context, 'Send Notifications', Icons.notifications_active, '/admin/notifications', const Color(0xFFE65100)),
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

  Widget _buildRecentActivityPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
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
}

