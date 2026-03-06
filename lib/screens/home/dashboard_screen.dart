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
                    ),
                  ],
                ),
              ),

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
