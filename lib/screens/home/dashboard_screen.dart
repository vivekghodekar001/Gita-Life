import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/japa_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final todayJapa = ref.watch(todayJapaLogProvider);
    final sessionsAsync = ref.watch(sessionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitaLife'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          )
        ],
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(
        children: [
          // const OfflineBanner(), // Uncomment if you implement connectivity checking
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Welcome Card
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hare Krishna, ${user?.displayName ?? 'Devotee'}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '"Always think of Me, become My devotee, worship Me and offer your homage unto Me."\n- Bhagavad Gita 18.65',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Grid of 6 feature cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    FeatureCard(
                      title: 'Gita Reader',
                      icon: Icons.book,
                      color: Colors.orange,
                      onTap: () => context.push('/gita'),
                    ),
                    FeatureCard(
                      title: 'Japa Counter',
                      icon: Icons.fingerprint,
                      color: Colors.brown,
                      onTap: () => context.push('/japa'),
                    ),
                    FeatureCard(
                      title: 'Audio',
                      icon: Icons.headphones,
                      color: Colors.teal,
                      onTap: () => context.push('/audio'),
                    ),
                    FeatureCard(
                      title: 'Lectures',
                      icon: Icons.video_library,
                      color: Colors.blue,
                      onTap: () => context.push('/lectures'),
                    ),
                    FeatureCard(
                      title: 'Attendance',
                      icon: Icons.calendar_today,
                      color: Colors.indigo,
                      onTap: () => context.push('/attendance/history'),
                    ),
                    FeatureCard(
                      title: 'Profile',
                      icon: Icons.person_outline,
                      color: Colors.purple,
                      onTap: () => context.push('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Today's Japa Progress
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Japa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        todayJapa.when(
                          data: (log) => Center(
                            child: Text(
                              '${log?.totalMalas ?? 0} Rounds / ${log?.totalBeads ?? 0} Mantras',
                              style: const TextStyle(fontSize: 20, color: Colors.orange),
                            ),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Text('Failed to load japa progress'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Upcoming Attendance Sessions Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Sessions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        sessionsAsync.when(
                          data: (sessions) {
                            if (sessions.isEmpty) return const Text('No recent sessions.');
                            final recent = sessions.take(3).toList();
                            return Column(
                              children: recent.map((s) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(s.title),
                                subtitle: Text(s.topic),
                                trailing: Text('${s.lectureDate.day}/${s.lectureDate.month}'),
                              )).toList(),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Text('Failed to load sessions'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
