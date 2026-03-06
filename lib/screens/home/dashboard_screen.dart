import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/japa_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showAllSessions = false;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isAdmin = userProfile?.role == 'admin';
    final todayJapa = ref.watch(todayJapaLogProvider);
    final sessionsAsync = ref.watch(sessionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
      appBar: AppBar(
        title: const Text('GitaLife'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF0D47A1), Color(0xFF00695C)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Welcome Card with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF00695C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hare Krishna,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (userProfile?.fullName.isNotEmpty == true)
                                  ? userProfile!.fullName.split(' ').first
                                  : 'Devotee',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🪷 Begin your sadhana today',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_stories, size: 36, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    FeatureCard(
                      title: 'Gita Reader',
                      icon: Icons.menu_book,
                      color: const Color(0xFF1565C0),
                      onTap: () => context.push('/gita'),
                    ),
                    FeatureCard(
                      title: 'Japa Counter',
                      icon: Icons.radio_button_checked,
                      color: const Color(0xFF00695C),
                      onTap: () => context.push('/japa'),
                    ),
                    FeatureCard(
                      title: 'Audio',
                      icon: Icons.headphones,
                      color: const Color(0xFF00ACC1),
                      onTap: () => context.push('/audio'),
                    ),
                    FeatureCard(
                      title: 'Lectures',
                      icon: Icons.video_library,
                      color: const Color(0xFF0D47A1),
                      onTap: () => context.push('/lectures'),
                    ),
                    FeatureCard(
                      title: 'Attendance',
                      icon: Icons.calendar_today,
                      color: const Color(0xFF1B5E20),
                      onTap: () => context.push('/attendance/history'),
                    ),
                    FeatureCard(
                      title: 'Assignments',
                      icon: Icons.assignment,
                      color: const Color(0xFF4527A0),
                      onTap: () => context.push('/assignments'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Admin Panel Card
                if (isAdmin)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF00695C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                      ),
                      title: const Text(
                        'Admin Panel',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        'Manage students, lectures & audio',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      onTap: () => context.push('/admin'),
                    ),
                  ),

                if (isAdmin) const SizedBox(height: 20),

                // Today's Japa Progress
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00695C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.radio_button_checked,
                                color: Color(0xFF00695C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Today's Japa",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        todayJapa.when(
                          data: (log) => Center(
                            child: Text(
                              '${log?.totalMalas ?? 0} Rounds / ${log?.totalBeads ?? 0} Mantras',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Text('Failed to load japa progress'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Attendance Sessions Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.event_note,
                                color: Color(0xFF1565C0),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Recent Sessions',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        sessionsAsync.when(
                          data: (sessions) {
                            if (sessions.isEmpty) return const Text('No recent sessions.');
                            final displaySessions =
                                _showAllSessions ? sessions : sessions.take(3).toList();
                            return Column(
                              children: [
                                ...displaySessions.map((s) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(s.title),
                                      subtitle: Text(s.topic),
                                      trailing: Text(
                                          '${s.lectureDate.day}/${s.lectureDate.month}'),
                                    )),
                                if (!_showAllSessions && sessions.length > 3)
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showAllSessions = true),
                                    child: const Text(
                                      'Show more',
                                      style: TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                                if (_showAllSessions && sessions.length > 3)
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showAllSessions = false),
                                    child: const Text(
                                      'Show less',
                                      style: TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Text('Failed to load sessions'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
