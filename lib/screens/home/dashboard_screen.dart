import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sacred_widgets.dart';
import '../../widgets/ancient_book_widget.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = -1; // No active tab — dashboard is separate

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isAdmin = userProfile?.role == 'admin';
<<<<<<< HEAD
    final firstName = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').first
        : 'Devotee';
    final initials = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFF080604),
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              // ── Header: Greeting + Avatar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hare Krishna,', style: SacredTextStyles.greeting()),
                        const SizedBox(height: 1),
                        Text(firstName, style: SacredTextStyles.userName()),
                      ],
                    ),
                    Row(
                      children: [
                        // Admin button
                        if (isAdmin)
                          GestureDetector(
                            onTap: () => context.push('/admin'),
                            child: Container(
                              width: 40, height: 40,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SacredColors.ember.withOpacity(0.08),
                                border: Border.all(color: SacredColors.ember.withOpacity(0.2)),
                              ),
                              child: Icon(Icons.admin_panel_settings, size: 18, color: SacredColors.ember.withOpacity(0.7)),
                            ),
                          ),
                        // Profile avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2A1A0A), Color(0xFF1A0E06)],
                              ),
                              border: Border.all(color: SacredColors.glassBorder),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      center: const Alignment(-0.3, -0.3),
                                      colors: [
                                        SacredColors.parchment.withOpacity(0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  initials,
                                  style: GoogleFonts.cormorantSc(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: SacredColors.parchment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                    ),
                  ],
                ),
              ),

<<<<<<< HEAD
              // ── Book fills remaining space ──
              Expanded(
                child: Center(
                  child: AncientBookWidget(
                    width: 220,
                    height: 300,
                    onTap: () => context.push('/gita'),
                  ),
                ),
              ),

              // ── 3D Glass Bottom Bar ──
              _GlassBottomBar(
                currentIndex: _navIndex,
                onTap: (index) {
                  setState(() => _navIndex = index);
                  switch (index) {
                    case 0: context.push('/japa'); break;
                    case 1: context.push('/lectures'); break;
                    case 2: context.push('/audio'); break;
                    case 3: context.push('/assignments'); break;
                  }
                },
              ),
            ],
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  3D Glassmorphism Bottom Bar
// ═══════════════════════════════════════════════════════════════

class _GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _BarItem(icon: Icons.radio_button_checked, label: 'Japa'),
    _BarItem(icon: Icons.play_circle_outline_rounded, label: 'Videos'),
    _BarItem(icon: Icons.headphones_rounded, label: 'Audios'),
    _BarItem(icon: Icons.assignment_rounded, label: 'Tasks'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Stack(
            children: [
              // 3D top highlight strip
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
              // Multi-layer 3D glass
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x20FFFFFF),
                  Color(0x0AFFFFFF),
                  Color(0x06FFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.6),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: SacredColors.parchment.withOpacity(0.04),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
                // Bottom depth shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                // Inner top highlight
                BoxShadow(
                  color: Colors.white.withOpacity(0.04),
                  blurRadius: 1,
                  spreadRadius: -1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isActive = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isActive
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                SacredColors.parchment.withOpacity(0.18),
                                SacredColors.parchment.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SacredColors.parchment.withOpacity(0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: SacredColors.parchment.withOpacity(0.08),
                                blurRadius: 12,
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: SacredColors.parchment.withOpacity(isActive ? 0.95 : 0.35),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label.toUpperCase(),
                          style: SacredTextStyles.sectionLabel(fontSize: 7).copyWith(
                            color: SacredColors.parchment.withOpacity(isActive ? 0.85 : 0.3),
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
            ], // Stack children
          ), // Stack
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
