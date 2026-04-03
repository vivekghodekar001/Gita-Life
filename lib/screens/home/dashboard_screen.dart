import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/update_service.dart';
import '../../widgets/sacred_widgets.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = -1; // No active tab — dashboard is separate

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isAdmin = userProfile?.role == 'admin';
    final isCounselor = userProfile?.role == 'counselor';
    final firstName = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').first
        : 'Devotee';
    final initials = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: SacredColors.ink,
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
                        // Counselor megaphone button
                        if (isCounselor)
                          GestureDetector(
                            onTap: () => context.push('/preaching'),
                            child: Container(
                              width: 40, height: 40,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A1A2E).withOpacity(0.08),
                                border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.campaign_outlined, size: 20, color: Color(0xFF1A1A2E)),
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
                    ),
                  ],
                ),
              ),

              // ── Gita Chariot Card ──
              Expanded(
                child: Center(
                  child: _buildGitaCard(context),
                ),
              ),

              // ── Pill Bottom Bar ──
              RepaintBoundary(
                child: _GlassBottomBar(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGitaCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/gita'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background chariot image — align top so Krishna & Arjuna are visible
                Image.asset(
                  'assets/images/b95e08551d7f75300abd54c93ee18263.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.4, 0.65, 1.0],
                    ),
                  ),
                ),
                // Text content at bottom
                Positioned(
                  bottom: 28,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BHAGAVAD GITA',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD4A017),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As It Is',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Open to read · swipe for verses',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Warm Parchment Pill Bottom Bar
// ═══════════════════════════════════════════════════════════════

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
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length * 2 - 1, (idx) {
              if (idx.isOdd) {
                // Vertical gold divider
                return Container(
                  width: 1,
                  height: 28,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: isActive
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x40D4AF37), Color(0x26B48C1E)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0x66B48C28), width: 1),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive
                            ? const Color(0xFF8B5E0A)
                            : const Color(0xFF64461A).withOpacity(0.50),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isActive
                              ? const Color(0xFF7A5008)
                              : const Color(0xFF64461A).withOpacity(0.55),
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
